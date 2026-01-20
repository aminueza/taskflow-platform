# Application Deployment via Terraform

This directory manages Container App deployments using Terraform.

## Overview

The deployment workflow automatically:
1. Builds and pushes Docker images to ACR
2. Generates `terraform.tfvars` from `terraform.tfvars.template`
3. Substitutes image digests and secrets
4. Deploys both API and Frontend apps via Terraform
5. Runs database migrations

**Note**: The `terraform.tfvars` file is generated from `terraform.tfvars.template` in CI/CD. For manual deployment, copy the template and fill in your values.

## Required GitHub Secrets

Set these secrets in your repository settings:

### Azure Authentication
- `AZURE_CLIENT_ID` - Service Principal Application ID
- `AZURE_CLIENT_SECRET` - Service Principal Secret
- `AZURE_SUBSCRIPTION_ID` - Azure Subscription ID
- `AZURE_TENANT_ID` - Azure Tenant ID

### Container Registry
- `ACR_LOGIN_SERVER` - e.g., `myregistry.azurecr.io`
- `ACR_USERNAME` - Registry username
- `ACR_PASSWORD` - Registry password

### Application Secrets
- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string (e.g., `redis://localhost:6379/0`)
- `SECRET_KEY_BASE` - Rails secret key base
- `API_URL` - API URL for frontend (set after first deployment)

## Initial Setup

### 1. Deploy Landing Zone First

```bash
cd ../landing_zone
terraform init
terraform apply
```

Save the outputs:
```bash
terraform output resource_group_name
terraform output container_environment_id
terraform output postgresql_connection_string
```

### 2. Set GitHub Secrets

Use the outputs from landing zone to set:
- `DATABASE_URL` = PostgreSQL connection string
- `REDIS_URL` = Redis connection string (if deployed)

### 3. First Deployment

Push code to main branch. The workflow will:
1. Deploy both apps
2. Output the URLs

### 4. Update API_URL Secret

After first deployment, get the API URL:
```bash
cd infrastructure/terraform/applications
terraform output container_app_urls
```

Set `API_URL` secret in GitHub to the API URL from output.

### 5. Redeploy Frontend

Push another commit or manually trigger the workflow to update frontend with correct API URL.

## Manual Deployment

You can also deploy manually:

```bash
# Copy template file
cp terraform.tfvars.template terraform.tfvars

# Edit terraform.tfvars and replace placeholders:
# - __API_IMAGE__ → your-registry.azurecr.io/api:latest
# - __FRONTEND_IMAGE__ → your-registry.azurecr.io/frontend:latest
# - __DATABASE_URL__ → postgresql://user:pass@host:5432/dbname
# - __REDIS_URL__ → redis://localhost:6379/0
# - __SECRET_KEY_BASE__ → your-secret-key-base
# - __API_URL__ → https://your-api-url.com

# Initialize and apply
terraform init
terraform apply
```

**Important**: CI/CD uses image digests (`@sha256:...`) for immutability, but you can use tags (`:latest`) for manual testing.

## Deployed Apps

### API
- **Image**: Built from `/api` directory
- **Port**: 3000
- **Resources**: 0.5 CPU, 1Gi memory
- **Environment**: Production Rails app

### Frontend
- **Image**: Built from `/frontend` directory
- **Port**: 80
- **Resources**: 0.25 CPU, 0.5Gi memory
- **Environment**: Production React app

## Scaling

Edit `terraform.tfvars.template` to change:
- `min_replicas` / `max_replicas` - Auto-scaling range
- `cpu` / `memory` - Resource allocation

## Outputs

After deployment, view:
```bash
terraform output container_app_urls
```

Example output:
```
{
  "api" = "https://ca-api-dev-weu.politebeach-12345678.westeurope.azurecontainerapps.io"
  "frontend" = "https://ca-frontend-dev-weu.politebeach-12345678.westeurope.azurecontainerapps.io"
}
```

## Troubleshooting

### Database Migrations Fail
Check database connection:
```bash
az containerapp exec \
  --name $(terraform output -raw api_container_app_name) \
  --resource-group $(terraform output -raw resource_group_name) \
  --command "bundle exec rails db:migrate:status"
```

### Frontend Can't Connect to API
1. Verify `API_URL` secret is set correctly
2. Check API is accessible: `curl <API_URL>/health`
3. Redeploy frontend after updating `API_URL`

### View Container Logs
```bash
az containerapp logs show \
  --name $(terraform output -raw api_container_app_name) \
  --resource-group $(terraform output -raw resource_group_name) \
  --follow
```
