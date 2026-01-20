# Bastion Proxy Setup

Access private Azure resources from your local machine via SSH SOCKS proxy through the bastion VM.

## Quick Setup

### Step 1: Get Credentials

```bash
cd infrastructure/terraform/landing_zone

# Get SSH private key
terraform output -raw bastion_ssh_private_key > ~/.ssh/bastion_key
chmod 600 ~/.ssh/bastion_key

# Get connection details
export BASTION_NAME=$(terraform output -raw azure_bastion_name)
export RG_NAME=$(terraform output -raw resource_group_name)
export VM_ID=$(terraform output -raw bastion_vm_id)
```

### Step 2: Create SSH Tunnel with SOCKS Proxy

**Terminal 1** - Create the tunnel:
```bash
# Create Azure Bastion tunnel on port 2222
az network bastion tunnel \
  --name $BASTION_NAME \
  --resource-group $RG_NAME \
  --target-resource-id $VM_ID \
  --resource-port 22 \
  --port 2222
```

**Terminal 2** - Create SOCKS proxy:
```bash
# Create SOCKS5 proxy on localhost:8080
ssh -i ~/.ssh/bastion_key \
  -p 2222 \
  -D 8080 \
  -C \
  -N \
  azureuser@localhost
```

**Explanation:**
- `-D 8080`: Dynamic port forwarding (SOCKS proxy) on port 8080
- `-C`: Compress data
- `-N`: Don't execute remote command (tunnel only)
- `-p 2222`: Connect to Azure Bastion tunnel port

### Step 3: Configure Your Applications

Now you can access private Azure resources through `localhost:8080` SOCKS proxy.

## Usage Examples

### A. Browser Access (Firefox)

**Configure Firefox:**
1. Settings → Network Settings → Manual proxy configuration
2. SOCKS Host: `localhost`
3. Port: `8080`
4. SOCKS v5: ✓
5. Proxy DNS when using SOCKS v5: ✓

**Or use FoxyProxy extension** for easy toggling.

**Access private resources:**
```
http://ca-rails-taskflow-dev-weu.internal.azurecontainerapps.io
http://psql-taskflow-dev-weu.postgres.database.azure.com
```

### B. Command Line with curl

```bash
# Access internal container app
curl --proxy socks5h://localhost:8080 \
  http://ca-rails-taskflow-dev-weu.internal.azurecontainerapps.io

# Access PostgreSQL (if needed)
psql "postgresql://user:pass@psql-taskflow-dev-weu.postgres.database.azure.com/database?sslmode=require" \
  --set PGOPTIONS="-c socks_proxy=localhost:8080"
```

### C. Git with SSH Proxy

```bash
# Set proxy for git
git config --global http.proxy socks5://localhost:8080
git config --global https.proxy socks5://localhost:8080

# Unset when done
git config --global --unset http.proxy
git config --global --unset https.proxy
```

### D. Python Requests

```python
import requests

proxies = {
    'http': 'socks5h://localhost:8080',
    'https': 'socks5h://localhost:8080'
}

response = requests.get(
    'http://ca-rails-taskflow-dev-weu.internal.azurecontainerapps.io',
    proxies=proxies
)
print(response.text)
```

### E. Docker with Proxy

```bash
# Run container with proxy
docker run --rm -it \
  -e HTTP_PROXY=socks5://host.docker.internal:8080 \
  -e HTTPS_PROXY=socks5://host.docker.internal:8080 \
  alpine sh
```

## Alternative: One-Line Tunnel Script

Create a script for convenience:

```bash
#!/bin/bash
# File: scripts/tunnel.sh

set -e

echo "🔐 Setting up SSH SOCKS proxy via Azure Bastion..."

# Get Terraform outputs
cd infrastructure/terraform/landing_zone

export BASTION_NAME=$(terraform output -raw azure_bastion_name)
export RG_NAME=$(terraform output -raw resource_group_name)
export VM_ID=$(terraform output -raw bastion_vm_id)
export SSH_KEY=~/.ssh/bastion_key

# Ensure SSH key exists
if [ ! -f "$SSH_KEY" ]; then
  echo "📥 Extracting SSH key..."
  terraform output -raw bastion_ssh_private_key > $SSH_KEY
  chmod 600 $SSH_KEY
fi

echo "🌐 Starting Azure Bastion tunnel on port 2222..."
az network bastion tunnel \
  --name $BASTION_NAME \
  --resource-group $RG_NAME \
  --target-resource-id $VM_ID \
  --resource-port 22 \
  --port 2222 &

BASTION_PID=$!
sleep 5  # Wait for tunnel to establish

echo "🔌 Starting SOCKS proxy on localhost:8080..."
ssh -i $SSH_KEY \
  -p 2222 \
  -D 8080 \
  -C \
  -N \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  azureuser@localhost &

SSH_PID=$!

echo "✅ Proxy ready! Use SOCKS5 proxy at localhost:8080"
echo ""
echo "📋 Test with:"
echo "  curl --proxy socks5h://localhost:8080 http://your-internal-service"
echo ""
echo "⏹️  Press Ctrl+C to stop"

# Cleanup on exit
trap "kill $BASTION_PID $SSH_PID 2>/dev/null" EXIT

wait
```

**Usage:**
```bash
chmod +x scripts/tunnel.sh
./scripts/tunnel.sh
```

## Advanced: Persistent HTTP Proxy on Bastion

If you want a persistent HTTP proxy (not SOCKS), add this to bastion initialization:

### Update bastion cloud-init

Add to `/modules/bastion/main.tf` custom_data:

```bash
# Install tinyproxy (lightweight HTTP proxy)
apt-get install -y tinyproxy

# Configure tinyproxy
cat > /etc/tinyproxy/tinyproxy.conf <<EOF
Port 8888
Listen 0.0.0.0
Allow 10.0.0.0/16
DisableViaHeader Yes
EOF

systemctl restart tinyproxy
systemctl enable tinyproxy
```

**Then use HTTP proxy:**
```bash
# Local port forward to bastion's tinyproxy
ssh -i ~/.ssh/bastion_key -p 2222 -L 8888:localhost:8888 azureuser@localhost

# Use HTTP proxy
curl --proxy http://localhost:8888 http://internal-service
```

## Troubleshooting

### Issue: "Connection refused" on port 2222
- Check Azure Bastion tunnel is running in Terminal 1
- Wait 5-10 seconds for tunnel to establish

### Issue: "Permission denied (publickey)"
- Ensure SSH key has correct permissions: `chmod 600 ~/.ssh/bastion_key`
- Verify key is correct: `terraform output -raw bastion_ssh_private_key`

### Issue: SOCKS proxy not working
- Verify SSH tunnel is running: `ps aux | grep "ssh.*8080"`
- Test locally: `curl --proxy socks5h://localhost:8080 http://google.com`

### Issue: DNS not resolving private names
- Use `socks5h://` (with 'h') not `socks5://`
- The 'h' makes DNS resolution happen on remote host

## Security Notes

- ⚠️ **Keep tunnel terminal open** - Closing it breaks the proxy
- 🔒 **Don't expose port 8080** to public networks
- 🔑 **Protect SSH private key** - Never commit to git
- ⏰ **Tunnel sessions timeout** - Azure Bastion has idle timeout (~4 hours)

## Browser Proxy Switching Tools

- **Firefox**: FoxyProxy extension
- **Chrome**: SwitchyOmega extension
- **System-wide**: ProxyCap (Windows), Proxifier (Mac)

## Summary

This setup gives you full access to private Azure resources from your local machine:

✅ Access internal container apps
✅ Connect to private PostgreSQL
✅ Query Key Vault (if needed)
✅ Debug private services
✅ No VPN required
✅ Complies with security requirements (no public IPs on VMs)
