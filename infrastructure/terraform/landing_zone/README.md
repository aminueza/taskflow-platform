# Landing Zone

Complete infrastructure setup including networking, compute, database, and container environment.

## What's Deployed

- **Resource Group**: Azure resource group
- **Network**: VNet with 4 subnets (bastion VM, Azure Bastion, apps, database)
- **Container Registry (ACR)**: Private Docker image registry for CI/CD
- **Key Vault**: VNet-protected secure storage with auto-generated SSH keys and database credentials
- **Azure Bastion Service**: Managed PaaS for secure SSH/RDP access (no public IP on VMs)
- **Bastion Host VM**: Ubuntu 24.04 VM with Puppet 8.x and Docker (private IP only)
- **PostgreSQL**: Azure PostgreSQL Flexible Server v17 (private)
- **Container Environment**: Azure Container Apps Environment with Log Analytics

## Prerequisites

- Terraform >= 1.14.0
- Azure CLI authenticated

## Deployment

1. Navigate to landing zone directory:
   ```bash
   cd landing_zone
   ```

2. Initialize and deploy:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

**Note:** SSH keys and database credentials are auto-generated and stored in Key Vault. No manual secrets required!

## Important Outputs

After deployment, retrieve auto-generated credentials:

```bash
# Get bastion SSH private key for access
terraform output -raw bastion_ssh_private_key > ~/.ssh/bastion_key
chmod 600 ~/.ssh/bastion_key

# Get database credentials
terraform output -raw db_admin_username
terraform output -raw db_admin_password

# Get ACR credentials
terraform output -raw acr_login_server
terraform output -raw acr_admin_username
terraform output -raw acr_admin_password

# Get Key Vault name
terraform output key_vault_name
```

## Accessing the Bastion VM

The bastion VM has **NO public IP** and must be accessed via Azure Bastion Service:

### Method 1: Azure Portal (GUI)
1. Go to Azure Portal → Virtual Machines
2. Select your bastion VM: `terraform output bastion_vm_name`
3. Click "Connect" → "Bastion"
4. Enter username: `azureuser`
5. Authentication: Upload SSH private key
6. Get SSH key: `terraform output -raw bastion_ssh_private_key > ~/.ssh/bastion_key`

### Method 2: Azure CLI (Tunnel)
```bash
# Get VM name
VM_NAME=$(terraform output -raw bastion_vm_name)
RG_NAME=$(terraform output -raw resource_group_name)

# Create SSH tunnel via Azure Bastion
az network bastion tunnel \
  --name $(terraform output -raw azure_bastion_name) \
  --resource-group $RG_NAME \
  --target-resource-id $(terraform output -raw bastion_vm_id) \
  --resource-port 22 \
  --port 2222

# In another terminal, connect via localhost
ssh -i ~/.ssh/bastion_key -p 2222 azureuser@localhost
```

**Note**: The bastion VM is on a private network only. This satisfies the requirement: "Must NOT run on a publicly reachable network."

## Accessing Private Resources via Proxy

To access private Azure resources (internal container apps, database, etc.) from your local machine, use the SSH SOCKS proxy:

### Quick Start

```bash
# From project root
./scripts/tunnel.sh
```

This creates a SOCKS5 proxy on `localhost:8080` that routes traffic through the bastion VM.

### Configure Your Browser

**Firefox:**
1. Settings → Network Settings → Manual proxy
2. SOCKS Host: `localhost`, Port: `8080`
3. SOCKS v5: ✓
4. Proxy DNS when using SOCKS v5: ✓

**Chrome/Edge:** Use SwitchyOmega extension

### Test Access

```bash
# Access internal container app
curl --proxy socks5h://localhost:8080 \
  http://ca-rails-taskflow-dev-weu.internal.azurecontainerapps.io

# Access any private resource
curl --proxy socks5h://localhost:8080 \
  http://<private-resource>
```

📖 **Full guide**: See [docs/BASTION_PROXY_SETUP.md](../../docs/BASTION_PROXY_SETUP.md)

## Security Features

- **VNet Isolation**: All resources deployed in private subnets
- **Key Vault Network ACLs**: Only application subnet can access secrets
- **PostgreSQL Private Access**: Database only accessible via bastion VM
- **Bastion VM Private Only**: No public IP, access via Azure Bastion Service only
- **No Public Endpoints on VMs**: Container apps are the only internet-facing application resources
- **Auto-generated Credentials**: No hardcoded secrets in code

## Next Steps

After deploying the landing zone, deploy container apps in `../applications/`.

## Build and Push Docker Images

After infrastructure is deployed:

```bash
# Login to ACR
ACR_SERVER=$(terraform output -raw acr_login_server)
ACR_PASSWORD=$(terraform output -raw acr_admin_password)
echo $ACR_PASSWORD | docker login $ACR_SERVER \
  -u $(terraform output -raw acr_admin_username) \
  --password-stdin

# Build and push your app
cd ../../api
docker build -t $ACR_SERVER/rails-api:latest .
docker push $ACR_SERVER/rails-api:latest

cd ../frontend
docker build -t $ACR_SERVER/frontend:latest .
docker push $ACR_SERVER/frontend:latest
```

## Modules Used

All modules are in `../modules/`:
- `resource_group/` - Azure resource group
- `network/` - VNet, subnets, NSGs
- `container_registry/` - Azure Container Registry (ACR)
- `key_vault/` - Key Vault with auto-generated secrets
- `azure_bastion/` - Azure Bastion Service (PaaS)
- `bastion/` - Bastion VM (private IP only)
- `postgresql/` - PostgreSQL database
- `container_env/` - Container Apps Environment
