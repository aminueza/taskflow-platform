#!/bin/bash
##########################################################
# SSH SOCKS Proxy via Azure Bastion
# Creates a tunnel to access private Azure resources
##########################################################

set -e

TERRAFORM_DIR="infrastructure/terraform/landing_zone"
SSH_KEY="${HOME}/.ssh/bastion_key"
SOCKS_PORT="${SOCKS_PORT:-8080}"
TUNNEL_PORT="${TUNNEL_PORT:-2222}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔐 Setting up SSH SOCKS proxy via Azure Bastion...${NC}"

# Check if in project root
if [ ! -d "$TERRAFORM_DIR" ]; then
  echo -e "${RED}❌ Error: Run this script from project root${NC}"
  echo "Current directory: $(pwd)"
  exit 1
fi

# Get Terraform outputs
echo -e "${YELLOW}📊 Getting Terraform outputs...${NC}"
cd "$TERRAFORM_DIR"

BASTION_NAME=$(terraform output -raw azure_bastion_name 2>/dev/null)
RG_NAME=$(terraform output -raw resource_group_name 2>/dev/null)
VM_ID=$(terraform output -raw bastion_vm_id 2>/dev/null)

if [ -z "$BASTION_NAME" ] || [ -z "$RG_NAME" ] || [ -z "$VM_ID" ]; then
  echo -e "${RED}❌ Error: Failed to get Terraform outputs. Is the infrastructure deployed?${NC}"
  exit 1
fi

cd - > /dev/null

# Ensure SSH key exists
if [ ! -f "$SSH_KEY" ]; then
  echo -e "${YELLOW}📥 Extracting SSH key...${NC}"
  cd "$TERRAFORM_DIR"
  terraform output -raw bastion_ssh_private_key > "$SSH_KEY"
  chmod 600 "$SSH_KEY"
  cd - > /dev/null
  echo -e "${GREEN}✅ SSH key saved to $SSH_KEY${NC}"
fi

# Check if ports are already in use
if lsof -Pi :${TUNNEL_PORT} -sTCP:LISTEN -t >/dev/null 2>&1 ; then
  echo -e "${YELLOW}⚠️  Port ${TUNNEL_PORT} already in use. Killing existing process...${NC}"
  lsof -ti :${TUNNEL_PORT} | xargs kill -9 2>/dev/null || true
  sleep 2
fi

if lsof -Pi :${SOCKS_PORT} -sTCP:LISTEN -t >/dev/null 2>&1 ; then
  echo -e "${YELLOW}⚠️  Port ${SOCKS_PORT} already in use. Killing existing process...${NC}"
  lsof -ti :${SOCKS_PORT} | xargs kill -9 2>/dev/null || true
  sleep 2
fi

# Start Azure Bastion tunnel
echo -e "${BLUE}🌐 Starting Azure Bastion tunnel on port ${TUNNEL_PORT}...${NC}"
az network bastion tunnel \
  --name "$BASTION_NAME" \
  --resource-group "$RG_NAME" \
  --target-resource-id "$VM_ID" \
  --resource-port 22 \
  --port "$TUNNEL_PORT" > /tmp/bastion_tunnel.log 2>&1 &

BASTION_PID=$!
echo "Azure Bastion PID: $BASTION_PID"

# Wait for tunnel to establish
echo -e "${YELLOW}⏳ Waiting for tunnel to establish...${NC}"
for i in {1..15}; do
  if lsof -Pi :${TUNNEL_PORT} -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Tunnel established${NC}"
    break
  fi
  if [ $i -eq 15 ]; then
    echo -e "${RED}❌ Tunnel failed to establish. Check logs: /tmp/bastion_tunnel.log${NC}"
    kill $BASTION_PID 2>/dev/null || true
    exit 1
  fi
  sleep 1
done

# Start SOCKS proxy
echo -e "${BLUE}🔌 Starting SOCKS5 proxy on localhost:${SOCKS_PORT}...${NC}"
ssh -i "$SSH_KEY" \
  -p "$TUNNEL_PORT" \
  -D "$SOCKS_PORT" \
  -C \
  -N \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o ServerAliveInterval=60 \
  -o ServerAliveCountMax=3 \
  azureuser@localhost > /tmp/socks_proxy.log 2>&1 &

SSH_PID=$!
echo "SSH SOCKS Proxy PID: $SSH_PID"

# Wait for SOCKS proxy
echo -e "${YELLOW}⏳ Waiting for SOCKS proxy...${NC}"
for i in {1..10}; do
  if lsof -Pi :${SOCKS_PORT} -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${GREEN}✅ SOCKS proxy ready${NC}"
    break
  fi
  if [ $i -eq 10 ]; then
    echo -e "${RED}❌ SOCKS proxy failed. Check logs: /tmp/socks_proxy.log${NC}"
    kill $BASTION_PID $SSH_PID 2>/dev/null || true
    exit 1
  fi
  sleep 1
done

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Proxy is ready!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}📋 SOCKS5 Proxy Configuration:${NC}"
echo -e "   Host: ${GREEN}localhost${NC}"
echo -e "   Port: ${GREEN}${SOCKS_PORT}${NC}"
echo ""
echo -e "${BLUE}🧪 Test with curl:${NC}"
echo -e "   ${YELLOW}curl --proxy socks5h://localhost:${SOCKS_PORT} http://google.com${NC}"
echo ""
echo -e "${BLUE}🌐 Browser configuration:${NC}"
echo -e "   1. Open browser proxy settings"
echo -e "   2. Set SOCKS5 proxy to: ${GREEN}localhost:${SOCKS_PORT}${NC}"
echo -e "   3. Enable 'Proxy DNS when using SOCKS v5'"
echo ""
echo -e "${BLUE}📖 Full guide: ${NC}infrastructure/docs/BASTION_PROXY_SETUP.md"
echo ""
echo -e "${RED}⏹️  Press Ctrl+C to stop the proxy${NC}"
echo ""

# Cleanup function
cleanup() {
  echo ""
  echo -e "${YELLOW}🧹 Cleaning up...${NC}"
  kill $BASTION_PID 2>/dev/null && echo "Stopped Azure Bastion tunnel" || true
  kill $SSH_PID 2>/dev/null && echo "Stopped SSH SOCKS proxy" || true
  echo -e "${GREEN}👋 Goodbye!${NC}"
  exit 0
}

trap cleanup EXIT INT TERM

# Keep script running
wait
