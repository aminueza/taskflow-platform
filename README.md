# TaskFlow Platform

Web application stack on Azure with Terraform, Puppet, and automated deployments.

[![Build Status](../../actions/workflows/application.yml/badge.svg)](../../actions/workflows/application.yml)
[![Infrastructure](../../actions/workflows/infrastructure.yml/badge.svg)](../../actions/workflows/infrastructure.yml)

## Stack

- Rails 7.1 API with PostgreSQL 17
- React frontend
- Azure Container Apps with auto-scaling
- Puppet-managed bastion host
- GitHub Actions CI/CD

## Architecture

```
Azure Resource Group
├─ Virtual Network (10.0.0.0/16)
│  ├─ Bastion Subnet (VM + Puppet + pgAdmin)
│  ├─ Apps Subnet (Rails + React + Redis)
│  └─ Database (PostgreSQL 17, private)
└─ Container Registry
```

Full diagram: [docs/INFRASTRUCTURE_DIAGRAM.md](docs/INFRASTRUCTURE_DIAGRAM.md)

## Quick Start

```bash
# Local development
./scripts/generate-secrets.sh
./scripts/quick-start.sh

# Deploy infrastructure (uses remote state in Azure Storage Account)
cd infrastructure/terraform/landing_zone
terraform apply

# Access bastion via SOCKS5 proxy
./scripts/tunnel.sh
```

See [DEVELOPER_GUIDE.md](docs/DEVELOPER_GUIDE.md) for details.

## Documentation

- [INFRASTRUCTURE_DIAGRAM.md](docs/INFRASTRUCTURE_DIAGRAM.md) - Architecture and network topology
- [DEVELOPER_GUIDE.md](docs/DEVELOPER_GUIDE.md) - Local setup, testing, deployment
- [ADMINISTRATOR_GUIDE.md](docs/ADMINISTRATOR_GUIDE.md) - Operations and database management
- [BASTION_PROXY_SETUP.md](docs/BASTION_PROXY_SETUP.md) - Proxy configuration

## Repository Structure

```
.
├── .github/workflows/       # CI/CD pipelines
├── api/                     # Rails 7.1 backend
├── frontend/                # React app
├── infrastructure/terraform/ # IaC modules
├── puppet/                  # Configuration management
├── docs/                    # Documentation
└── scripts/                 # Helper scripts
```

## Technology

| Component | Stack |
|-----------|-------|
| Frontend | React 18 + Nginx |
| Backend | Rails 7.1 + Puma |
| Database | PostgreSQL 17 |
| Cache | Redis 7 |
| Platform | Azure Container Apps |
| IaC | Terraform |
| Config | Puppet |
| CI/CD | GitHub Actions |

## License

MIT
