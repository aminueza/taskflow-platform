# Key Vault Module

Simplified Key Vault module that auto-generates and securely stores SSH keys and database credentials.

## Features

- **Auto-generates SSH key pair** (4096-bit RSA) for bastion VM access
- **Auto-generates PostgreSQL credentials** (secure username and password)
- **Stores all secrets** in Azure Key Vault
- **RBAC-enabled** for secure access control
- **VNet-protected** - Network ACLs restrict access to application subnet only

## What's Created

1. **Azure Key Vault** - Secure secrets storage
2. **SSH Keys** - Auto-generated and stored in Key Vault:
   - `bastion-ssh-private-key` - Private key for SSH access
   - `bastion-ssh-public-key` - Public key for VM configuration
3. **Database Credentials** - Auto-generated and stored in Key Vault:
   - `postgresql-admin-username` - Random 16-character username
   - `postgresql-admin-password` - Random 32-character secure password

## Usage

```hcl
module "key_vault" {
  source = "../modules/key_vault"

  resource_group_name = azurerm_resource_group.main.name
  global_config       = local.common_tags
  app_subnet_id       = module.network.subnet_ids["apps"]
}
```

## Outputs

All outputs are marked as sensitive:

- `key_vault_id` - Key Vault resource ID
- `key_vault_name` - Key Vault name
- `key_vault_uri` - Key Vault URI
- `bastion_ssh_public_key` - Auto-generated SSH public key
- `bastion_ssh_private_key` - Auto-generated SSH private key
- `db_admin_username` - Auto-generated PostgreSQL username
- `db_admin_password` - Auto-generated PostgreSQL password

## Accessing Secrets

### Via Terraform Outputs

```bash
# Get SSH private key
terraform output -raw bastion_ssh_private_key > ~/.ssh/bastion_key
chmod 600 ~/.ssh/bastion_key

# Get database credentials
terraform output -raw db_admin_username
terraform output -raw db_admin_password
```

### Via Azure CLI

```bash
# Get Key Vault name
KV_NAME=$(terraform output -raw key_vault_name)

# Retrieve secrets
az keyvault secret show --vault-name $KV_NAME --name bastion-ssh-private-key --query value -o tsv
az keyvault secret show --vault-name $KV_NAME --name postgresql-admin-username --query value -o tsv
az keyvault secret show --vault-name $KV_NAME --name postgresql-admin-password --query value -o tsv
```

## Security Features

- **RBAC Authorization** - Role-based access control enabled
- **Network Isolation** - Network ACLs deny all traffic except from application subnet
- **Secure Generation** - Cryptographically secure random generation
- **Automatic Rotation** - Secrets can be rotated by destroying and recreating resources
- **Audit Logging** - All access logged via Azure Monitor

## Network Protection

The Key Vault is protected by network ACLs:
- **Default Action**: Deny all traffic
- **Allowed**: Application subnet only (where Container Apps run)
- **Bypass**: Azure trusted services

This ensures only Container Apps can access secrets directly. Terraform operations during deployment are handled via Azure trusted services bypass (when running from Azure DevOps, GitHub Actions with Azure credentials, or Azure Cloud Shell).

## Providers Required

- `azurerm` >= 4.0.0
- `random` ~> 3.5
- `tls` ~> 4.0
