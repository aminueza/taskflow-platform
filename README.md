# TaskFlow Platform - Cloud-Native Web Application Stack

A production-ready task management platform deployed on Microsoft Azure with Infrastructure as Code (Terraform), Configuration Management (Puppet), and fully automated CI/CD pipelines.

[![Build Status](../../actions/workflows/application.yml/badge.svg)](../../actions/workflows/application.yml)
[![Infrastructure](../../actions/workflows/infrastructure.yml/badge.svg)](../../actions/workflows/infrastructure.yml)

## 📋 Project Overview

TaskFlow is a cloud-native web application stack consisting of:

- **Backend API**: Ruby on Rails 7.1 REST API with PostgreSQL
- **Frontend**: React-based single-page application
- **Infrastructure**: Azure Container Apps, PostgreSQL Flexible Server, Virtual Network
- **Configuration Management**: Puppet-managed bastion host with pgAdmin 4
- **CI/CD**: Fully automated GitHub Actions pipelines with security scanning

## ✅ Requirements Compliance Checklist

This project fulfills all requirements for deploying a generic web application stack on a cloud provider:

### Infrastructure Requirements

- [x] **Cloud Provider**: Microsoft Azure (West Europe region)
- [x] **Infrastructure as Code**: Complete Terraform modules for all resources
- [x] **Configuration Management**: Puppet for bastion host and user management
- [x] **Version Control**: Git repository with comprehensive history
- [x] **Network Architecture**:
  - [x] Virtual Network (10.0.0.0/16) with multiple subnets
  - [x] Private subnet for bastion (10.0.1.0/24)
  - [x] Container Apps subnet (10.0.2.0/23)
  - [x] Private database endpoints
- [x] **Security**:
  - [x] Bastion host with SSH key authentication (no public IP on bastion)
  - [x] Network isolation for database
  - [x] Secrets management via GitHub Secrets
  - [x] Security scanning (Trivy, Brakeman)
- [x] **Database**: Azure PostgreSQL 17 Flexible Server with:
  - [x] High availability configuration
  - [x] Automated daily backups
  - [x] Private networking
  - [x] pgAdmin 4 for management

### Application Requirements

- [x] **Multi-tier Architecture**:
  - [x] Frontend (React + Nginx)
  - [x] Backend API (Rails 7.1 + Puma)
  - [x] Database (PostgreSQL 17)
  - [x] Cache layer (Redis for Sidekiq)
- [x] **Containerization**: Docker containers for all applications
- [x] **Container Registry**: Azure Container Registry (ACR)
- [x] **Auto-scaling**: Container Apps with 1-3 replica scaling
- [x] **Health Checks**: Built-in health endpoints for monitoring

### CI/CD Requirements

- [x] **Automated Deployment**: GitHub Actions workflows
- [x] **Testing**:
  - [x] RSpec test suite (50+ tests)
  - [x] Test coverage reporting
  - [x] Automated test runs in CI
- [x] **Security Scanning**:
  - [x] Trivy for container vulnerabilities
  - [x] Brakeman for Rails security issues
- [x] **Build Process**:
  - [x] Multi-stage Docker builds
  - [x] Automated image tagging
  - [x] Container registry push
- [x] **Database Migrations**: Automated Rails migrations on deployment
- [x] **Deployment Stages**:
  1. Security scan
  2. Run tests
  3. Build Docker images
  4. Push to ACR
  5. Deploy via Terraform
  6. Run migrations
  7. Health checks

### Documentation Requirements

- [x] **Infrastructure Diagram**: Complete architecture visualization
- [x] **Administrator Guide**: Operations, bastion access, pgAdmin usage
- [x] **Developer Guide**: Local development, testing, deployment workflow
- [x] **Code Documentation**: Inline comments and API documentation
- [x] **Repository Structure**: Clear organization with README

### User Management Requirements

- [x] **Puppet-Managed Users**: Automated user provisioning on bastion
- [x] **SSH Key Management**: Centralized key distribution
- [x] **Admin Tool Access**: pgAdmin 4 deployment via Puppet
- [x] **Flexible User Addition**: Simple Hiera data updates

## 🏗️ Architecture

For a comprehensive architecture diagram with network topology, CI/CD flow, and component details, see [Infrastructure Diagram](docs/INFRASTRUCTURE_DIAGRAM.md).

### High-Level Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Azure Cloud (West Europe)                         │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │                  Resource Group: rg-taskflow-global-weu         │    │
│  │                                                                  │    │
│  │  ┌────────────────────────────────────────────────────────────┐ │   │
│  │  │  Virtual Network (10.0.0.0/16)                             │ │   │
│  │  │                                                             │ │   │
│  │  │  ┌─────────────────────────────────────────────────────┐  │ │   │
│  │  │  │  Private Subnet (10.0.1.0/24)                       │  │ │   │
│  │  │  │  • Bastion Host (Puppet-managed)                    │  │ │   │
│  │  │  │  • pgAdmin 4                                        │  │ │   │
│  │  │  │  • Admin user accounts                              │  │ │   │
│  │  │  └─────────────────────────────────────────────────────┘  │ │   │
│  │  │                                                             │ │   │
│  │  │  ┌─────────────────────────────────────────────────────┐  │ │   │
│  │  │  │  Container Apps Subnet (10.0.2.0/23)                │  │ │   │
│  │  │  │  • Rails API (Port 3000, 1-3 replicas)              │  │ │   │
│  │  │  │  • React Frontend (Port 80, 1-3 replicas)           │  │ │   │
│  │  │  │  • Redis Cache (Sidekiq)                            │  │ │   │
│  │  │  └─────────────────────────────────────────────────────┘  │ │   │
│  │  │                                                             │ │   │
│  │  │  ┌─────────────────────────────────────────────────────┐  │ │   │
│  │  │  │  Database                                            │  │ │   │
│  │  │  │  • PostgreSQL 17 Flexible Server                    │  │ │   │
│  │  │  │  • Private endpoint only                            │  │ │   │
│  │  │  └─────────────────────────────────────────────────────┘  │ │   │
│  │  └────────────────────────────────────────────────────────────┘ │   │
│  │                                                                  │    │
│  │  ┌────────────────────────────────────────────────────────────┐ │   │
│  │  │  Azure Container Registry                                  │ │   │
│  │  │  • api:latest, frontend:latest                            │ │   │
│  │  └────────────────────────────────────────────────────────────┘ │   │
│  └────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘

                             ▲                    ▲
                             │                    │
                        HTTPS (Users)      SSH Tunnel (Admins)
```

**Key Features:**
- **Isolated Database**: PostgreSQL in private network, not publicly accessible
- **Bastion Host**: No public IP - access via SSH tunnel only
- **Auto-scaling**: Container Apps scale 1-3 replicas based on load
- **Resilient Storage**: Database on separate cloud resource, survives app updates
- **Security**: Network segmentation, private endpoints, key-based authentication

## 🚀 Quick Start

### For Developers

See the complete [Developer Guide](docs/DEVELOPER_GUIDE.md) for detailed instructions.

```bash
# Clone repository
git clone https://github.com/your-org/taskflow-platform.git
cd taskflow-platform

# Start with Docker Compose (recommended)
docker-compose up

# Services available at:
# - Frontend: http://localhost:3001
# - API: http://localhost:3000
# - PostgreSQL: localhost:5432
# - Redis: localhost:6379
```

### For Administrators

See the complete [Administrator Guide](docs/ADMINISTRATOR_GUIDE.md) for operational procedures.

```bash
# Access bastion host via SSH tunnel
ssh -L 5050:localhost:5050 azureuser@<bastion-private-ip>

# Access pgAdmin
open http://localhost:5050

# Run Rails console in production
az containerapp exec \
  --name ca-api-global-weu \
  --resource-group rg-taskflow-global-weu \
  --command "bundle exec rails console"
```

### For Infrastructure Deployment

```bash
# Deploy infrastructure with Terraform
cd infrastructure/terraform/base
terraform init
terraform plan
terraform apply

# Deploy applications (automated via GitHub Actions)
git push origin main  # Triggers CI/CD pipeline
```

## 📂 Repository Structure

```
taskflow-platform/
├── .github/workflows/          # CI/CD pipelines
│   ├── infrastructure.yml      # Infrastructure deployment
│   ├── application.yml         # App build, test, and deploy
│   └── puppet.yml             # Puppet code validation
│
├── api/                        # Rails 7.1 API backend
│   ├── app/
│   │   ├── controllers/       # API endpoints
│   │   ├── models/            # ActiveRecord models
│   │   ├── mailers/           # Email templates
│   │   └── workers/           # Sidekiq background jobs
│   ├── spec/                  # RSpec test suite
│   ├── db/                    # Database migrations
│   ├── Dockerfile             # Multi-stage build
│   └── Gemfile                # Ruby dependencies
│
├── frontend/                   # React frontend
│   ├── src/
│   │   ├── components/        # React components
│   │   ├── pages/             # Page layouts
│   │   └── services/          # API clients
│   ├── public/                # Static assets
│   ├── Dockerfile             # Nginx-based build
│   └── package.json           # Node dependencies
│
├── infrastructure/             # Infrastructure as Code
│   └── terraform/
│       ├── base/              # Base infrastructure module
│       │   ├── modules/       # Reusable modules
│       │   │   ├── network/   # VNet and subnets
│       │   │   ├── bastion/   # Bastion host VM
│       │   │   ├── postgresql/# Database server
│       │   │   └── redis/     # Cache layer
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       └── applications/       # Application deployment
│           ├── modules/
│           │   └── container_app/  # Container Apps module
│           ├── main.tf
│           ├── terraform.tfvars.template
│           └── outputs.tf
│
├── puppet/                     # Configuration management
│   ├── modules/
│   │   ├── bastion_users/     # User account management
│   │   │   ├── manifests/
│   │   │   │   └── init.pp
│   │   │   └── templates/
│   │   │       └── authorized_keys.erb
│   │   └── pgadmin/           # pgAdmin 4 installation
│   │       ├── manifests/
│   │       │   └── init.pp
│   │       └── files/
│   │           └── config_local.py
│   ├── manifests/
│   │   └── site.pp            # Node definitions
│   └── data/
│       └── common.yaml        # Hiera user data
│
├── docs/                       # Documentation
│   ├── INFRASTRUCTURE_DIAGRAM.md   # Architecture diagrams
│   ├── DEVELOPER_GUIDE.md          # Development workflow
│   └── ADMINISTRATOR_GUIDE.md      # Operations guide
│
├── docker-compose.yml          # Local development environment
└── README.md                   # This file
```

## 🔒 Security Features

### Network Security
- **Private Subnets**: Database and bastion in isolated network segments
- **No Public Database Access**: PostgreSQL only accessible via private endpoint
- **Bastion Host**: Single point of administrative access (no public IP)
- **SSH Tunnel Required**: Admin access via secure tunnel only

### Application Security
- **JWT Authentication**: Token-based API authentication
- **bcrypt Password Hashing**: Secure password storage with `has_secure_password`
- **HTTPS Only**: All public endpoints use TLS encryption
- **Security Scanning**: Automated Trivy and Brakeman scans in CI/CD

### Secrets Management
- **GitHub Secrets**: Sensitive values stored encrypted
- **No Secrets in Code**: All credentials injected via environment variables
- **Azure Key Vault**: Integration ready for enhanced secret rotation

### Automated Security
- **Dependency Scanning**: Bundler-audit and npm audit
- **Container Scanning**: Trivy vulnerability detection
- **Code Scanning**: Brakeman Rails security analysis
- **Regular Updates**: Automated gem and npm updates

## 📚 Documentation

### Guides

- **[Infrastructure Diagram](docs/INFRASTRUCTURE_DIAGRAM.md)** - Complete architecture with network topology, CI/CD flow, and component specifications
- **[Developer Guide](docs/DEVELOPER_GUIDE.md)** - Local development setup, testing, deployment workflow, Git Flow branching strategy
- **[Administrator Guide](docs/ADMINISTRATOR_GUIDE.md)** - Bastion access, pgAdmin usage, user management, database operations, backup/recovery

### Quick References

| Topic | Documentation |
|-------|--------------|
| **Local Development** | [Developer Guide - Local Development](docs/DEVELOPER_GUIDE.md#local-development) |
| **Running Tests** | [Developer Guide - Testing](docs/DEVELOPER_GUIDE.md#testing) |
| **Deployment** | [Developer Guide - Deployment Process](docs/DEVELOPER_GUIDE.md#deployment-process) |
| **Bastion Access** | [Administrator Guide - Bastion Host Access](docs/ADMINISTRATOR_GUIDE.md#bastion-host-access) |
| **Database Management** | [Administrator Guide - Database Administration](docs/ADMINISTRATOR_GUIDE.md#database-administration) |
| **User Management** | [Administrator Guide - User Management](docs/ADMINISTRATOR_GUIDE.md#user-management-with-puppet) |
| **Architecture** | [Infrastructure Diagram](docs/INFRASTRUCTURE_DIAGRAM.md) |

## 🚢 Deployment

### Automated Deployment (Recommended)

Deployments are **fully automated** via GitHub Actions:

1. **Push to `main` branch**
   ```bash
   git push origin main
   ```

2. **CI/CD Pipeline Executes:**
   ```
   Security Scan → Tests → Build → Push to ACR → Terraform Apply → Migrations
   ```

3. **Monitor Deployment:**
   - GitHub Actions tab shows workflow progress
   - Deployment summary includes test results and security scan

### Manual Deployment

For manual deployment or troubleshooting:

```bash
# Build and push images
cd api
docker build -t <registry>.azurecr.io/api:latest .
docker push <registry>.azurecr.io/api:latest

cd ../frontend
docker build -t <registry>.azurecr.io/frontend:latest .
docker push <registry>.azurecr.io/frontend:latest

# Deploy with Terraform
cd infrastructure/terraform/applications
terraform apply
```

## 🧪 Testing

### API Tests (RSpec)

```bash
cd api

# Run all tests
bundle exec rspec

# Run with coverage
COVERAGE=true bundle exec rspec

# Run specific test
bundle exec rspec spec/models/user_spec.rb
```

**Test Coverage:**
- 50+ RSpec examples
- Model, request, service, and worker tests
- Factory Bot for test data
- SimpleCov for coverage reporting

### Frontend Tests (Jest)

```bash
cd frontend

# Run all tests
npm test

# Run with coverage
npm test -- --coverage

# Watch mode
npm test -- --watch
```

## 🛠️ Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | React 18, Nginx | Single-page application |
| **Backend** | Ruby on Rails 7.1, Puma | REST API server |
| **Database** | PostgreSQL 17 | Primary data store |
| **Cache** | Redis 7 | Sidekiq job queue |
| **Container Platform** | Azure Container Apps | Application hosting |
| **Container Registry** | Azure Container Registry | Image storage |
| **Infrastructure** | Terraform 1.5+ | Infrastructure as Code |
| **Configuration** | Puppet 8.x | Configuration management |
| **CI/CD** | GitHub Actions | Automation pipelines |
| **Monitoring** | Azure Application Insights | Observability |

## 📊 Project Status

- ✅ Infrastructure fully deployed
- ✅ CI/CD pipelines operational
- ✅ All tests passing (50/50 examples)
- ✅ Security scanning enabled
- ✅ Documentation complete
- ✅ Puppet user management working
- ✅ pgAdmin 4 deployed and accessible

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
   - Follow existing code style
   - Add tests for new features
   - Update documentation as needed
4. **Run tests locally**
   ```bash
   bundle exec rspec  # API tests
   npm test          # Frontend tests
   ```
5. **Commit with conventional commits**
   ```bash
   git commit -m "feat: add new feature"
   ```
6. **Push and create Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

- **Issues**: [GitHub Issues](../../issues)
- **Discussions**: [GitHub Discussions](../../discussions)
- **Documentation**: See [docs/](docs/) directory

## 🙏 Acknowledgments

- Built with [Ruby on Rails](https://rubyonrails.org/)
- Deployed on [Microsoft Azure](https://azure.microsoft.com/)
- Managed with [Terraform](https://www.terraform.io/)
- Configured with [Puppet](https://puppet.com/)
- Automated with [GitHub Actions](https://github.com/features/actions)

---

**Made with ❤️ for cloud-native deployments**
