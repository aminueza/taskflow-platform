# Web Application Stack - Azure DevOps Challenge

A production-ready web application stack deployed on Microsoft Azure with Infrastructure as Code (Terraform), configuration management (Puppet), and CI/CD automation.

## 📋 Overview

This solution demonstrates:
- **Infrastructure as Code**: Terraform modules for Azure resources
- **Configuration Management**: Puppet for bastion host user management and pgAdmin deployment
- **CI/CD**: GitHub Actions for automated infrastructure and application deployment
- **Security**: Private network architecture with bastion host access
- **Database Management**: Azure PostgreSQL Flexible Server with pgAdmin

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure Subscription                        │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  VNet (10.0.0.0/16)                                  │  │
│  │                                                       │  │
│  │  ├─ Bastion Subnet (10.0.1.0/24)                    │  │
│  │  │  └─ Bastion VM (Puppet-managed users + pgAdmin)  │  │
│  │  │                                                    │  │
│  │  ├─ Apps Subnet (10.0.2.0/24)                       │  │
│  │  │  └─ Container Apps (Rails API + Frontend)        │  │
│  │  │                                                    │  │
│  │  └─ Database Subnet (10.0.3.0/24)                   │  │
│  │     └─ PostgreSQL Flexible Server                   │  │
│  │                                                       │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- **Azure Subscription**
- **Terraform** >= 1.5.0
- **Puppet** >= 8.0
- **Docker** (for local development)
- **Git**

### 1. Deploy Infrastructure

```bash
# Navigate to Terraform directory
cd infrastructure/terraform

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
# - bastion_admin_ssh_key
# - db_admin_password

# Initialize and deploy
terraform init
terraform plan
terraform apply
```

### 2. Configure Bastion Host

```bash
# Get bastion IP from Terraform output
bastion_ip=$(terraform output -raw bastion_public_ip)

# SSH to bastion
ssh azureuser@$bastion_ip

# On bastion: Clone Puppet config
sudo git clone <your-repo-url> /etc/puppetlabs/code

# Apply Puppet configuration
sudo puppet apply /etc/puppetlabs/code/manifests/site.pp
```

### 3. Deploy Application

The application is automatically deployed via GitHub Actions when you push to the `main` branch.

Manual deployment:
```bash
# Build and push Docker images
cd rails-app
docker build -t <your-acr>.azurecr.io/rails-api:latest .
docker push <your-acr>.azurecr.io/rails-api:latest

# Update container app
az containerapp update \
  --name ca-rails-webapp-dev-weu \
  --resource-group rg-webapp-dev-weu \
  --image <your-acr>.azurecr.io/rails-api:latest
```

### 4. Access Services

- **Application**: `https://<container-app-fqdn>` (from Terraform output)
- **pgAdmin**: `http://<bastion-ip>:5050`
- **Bastion SSH**: `ssh azureuser@<bastion-ip>`

## 📂 Project Structure

```
├── .github/workflows/      # CI/CD pipelines
│   ├── infrastructure.yml  # Terraform deployment
│   ├── application.yml     # App build and deploy
│   └── puppet.yml          # Puppet validation
├── infrastructure/
│   └── terraform/          # Terraform modules
│       ├── modules/
│       │   ├── network/    # VNet and subnets
│       │   ├── bastion/    # Bastion VM
│       │   ├── postgresql/ # Database
│       │   └── container_apps/ # App hosting
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── puppet/
│   ├── modules/
│   │   ├── bastion_users/  # User management
│   │   └── pgadmin/        # Database admin tool
│   ├── manifests/
│   │   └── site.pp         # Node definitions
│   └── data/
│       └── common.yaml     # Hiera data
├── rails-app/              # Rails API application
│   ├── Dockerfile
│   ├── app/
│   └── spec/
├── frontend/               # React frontend
│   ├── Dockerfile
│   └── src/
└── docs/                   # Documentation
    ├── ADMIN_GUIDE.md
    └── DEVELOPER_GUIDE.md
```

## 🔒 Security

- **Network Isolation**: Private subnets for apps and database
- **Bastion Access**: Single point of entry for administrative access
- **Puppet-Managed Users**: Centralized SSH key management
- **Database Security**: Private endpoint, SSL required
- **Secrets Management**: Stored in GitHub Secrets, not in code

## 📚 Documentation

- [Administrator Guide](docs/ADMIN_GUIDE.md) - Bastion access, pgAdmin, operations
- [Developer Guide](docs/DEVELOPER_GUIDE.md) - Local development, deployment

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with Docker Compose
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## 📞 Support

For issues or questions, please open a GitHub issue.
