# Azure Container Registry (ACR) Module

Simplified ACR module for storing Docker images for CI/CD pipelines.

## Features

- **Private Docker registry** for your container images
- **Admin user enabled** by default (for easy CI/CD integration)
- **Standard SKU** - good balance of features and cost
- **Automatic naming** via label module

## What's Created

- **Azure Container Registry** - Private Docker image registry
- Registry name format: `acr{application_name}{environment}{location_acronym}`
- Example: `acrtaskflowglobalweu`

## Usage

```hcl
module "container_registry" {
  source = "../modules/container_registry"

  resource_group_name = azurerm_resource_group.main.name
  global_config       = local.common_tags
  sku                 = "Standard"
  admin_enabled       = true
}
```

## Parameters

**Required:**
- `resource_group_name` - Resource group name
- `global_config` - Global configuration object

**Optional:**
- `sku` - SKU tier: `Basic`, `Standard`, or `Premium` (default: `Standard`)
- `admin_enabled` - Enable admin user (default: `true`)

## SKU Comparison

| Feature | Basic | Standard | Premium |
|---------|-------|----------|---------|
| Storage | 10 GB | 100 GB | 500 GB |
| Webhooks | 2 | 10 | 500 |
| Geo-replication | ❌ | ❌ | ✅ |
| Content trust | ❌ | ❌ | ✅ |
| Private endpoints | ❌ | ❌ | ✅ |
| **Price/month** | ~$5 | ~$20 | ~$165 |

**Recommendation**: Use `Standard` for most workloads.

## Outputs

- `registry_id` - ACR resource ID
- `registry_name` - ACR name
- `login_server` - Login server URL (e.g., `acrtaskflowglobalweu.azurecr.io`)
- `admin_username` - Admin username (sensitive)
- `admin_password` - Admin password (sensitive)

## Docker Login

### Method 1: Admin Credentials

```bash
# Get credentials from Terraform
ACR_SERVER=$(terraform output -raw acr_login_server)
ACR_USERNAME=$(terraform output -raw acr_admin_username)
ACR_PASSWORD=$(terraform output -raw acr_admin_password)

# Docker login
echo $ACR_PASSWORD | docker login $ACR_SERVER -u $ACR_USERNAME --password-stdin
```

### Method 2: Azure CLI (Recommended for local dev)

```bash
# Login using Azure identity
az acr login --name $(terraform output -raw acr_name)
```

## Build and Push Images

```bash
# Build image
docker build -t myapp:latest .

# Tag for ACR
ACR_SERVER=$(terraform output -raw acr_login_server)
docker tag myapp:latest $ACR_SERVER/myapp:latest

# Push to ACR
docker push $ACR_SERVER/myapp:latest
```

## Use in Container Apps

Update your `container_apps` variable:

```hcl
container_apps = {
  rails = {
    container_name = "rails-api"
    image          = "acrtaskflowglobalweu.azurecr.io/rails-api:latest"
    cpu            = 0.5
    memory         = "1Gi"
    # ...
  }
}
```

## CI/CD Integration

### GitHub Actions

```yaml
- name: Login to ACR
  uses: docker/login-action@v2
  with:
    registry: ${{ secrets.ACR_LOGIN_SERVER }}
    username: ${{ secrets.ACR_USERNAME }}
    password: ${{ secrets.ACR_PASSWORD }}

- name: Build and push
  run: |
    docker build -t ${{ secrets.ACR_LOGIN_SERVER }}/myapp:${{ github.sha }} .
    docker push ${{ secrets.ACR_LOGIN_SERVER }}/myapp:${{ github.sha }}
```

### Azure DevOps

```yaml
- task: Docker@2
  inputs:
    containerRegistry: 'ACR Service Connection'
    repository: 'myapp'
    command: 'buildAndPush'
    Dockerfile: 'Dockerfile'
    tags: |
      $(Build.BuildId)
      latest
```

## Security Notes

- ⚠️ Admin credentials are stored in Terraform state (encrypted)
- 🔒 For production, consider using Azure service principals instead of admin user
- 🔐 Rotate admin password periodically
- 📋 Use Azure RBAC for fine-grained access control

## Common Commands

```bash
# List images
az acr repository list --name $(terraform output -raw acr_name)

# Show image tags
az acr repository show-tags \
  --name $(terraform output -raw acr_name) \
  --repository myapp

# Delete old images
az acr repository delete \
  --name $(terraform output -raw acr_name) \
  --image myapp:old-tag
```

## Pricing

**Standard SKU**: ~$20/month + storage costs
- First 100 GB storage included
- $0.10/GB for additional storage
- Data transfer: Standard Azure rates

**Optimization tips:**
- Clean up old images regularly
- Use image retention policies (Premium SKU)
- Compress images to reduce storage

## Troubleshooting

### Issue: "unauthorized: authentication required"
**Solution**: Run `docker login` or `az acr login`

### Issue: ACR name already exists
**Solution**: ACR names must be globally unique. Change `application_name` or `environment`

### Issue: Cannot push large images
**Solution**: Increase Docker client timeout or upgrade to Premium SKU for better bandwidth

## Next Steps

1. Deploy the landing zone with ACR
2. Build and push your Docker images
3. Update container apps to use ACR images
4. Set up CI/CD pipeline to automate builds
