# TaskFlow Platform - Infrastructure Diagram

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            Azure Cloud (West Europe)                         │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                    Resource Group: rg-taskflow-dev-weu                  │ │
│  │                                                                          │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐  │ │
│  │  │                     Virtual Network (VNet)                        │  │ │
│  │  │                     10.0.0.0/16                                   │  │ │
│  │  │                                                                    │  │ │
│  │  │  ┌─────────────────────────────────────────────────────────────┐ │  │ │
│  │  │  │  Private Subnet (10.0.1.0/24)                               │ │  │ │
│  │  │  │                                                              │ │  │ │
│  │  │  │  ┌────────────────────┐                                     │ │  │ │
│  │  │  │  │   Bastion Host     │  ← NOT publicly accessible          │ │  │ │
│  │  │  │  │   (Ubuntu 24.04)   │                                     │ │  │ │
│  │  │  │  │                    │  Managed by Puppet:                 │ │  │ │
│  │  │  │  │  - Admin Users     │  • User credentials                 │ │  │ │
│  │  │  │  │  - pgAdmin 4       │  • pgAdmin installation             │ │  │ │
│  │  │  │  │  - SSH Access      │  • System configuration             │ │  │ │
│  │  │  │  │                    │                                     │ │  │ │
│  │  │  │  │  Private IP only   │                                     │ │  │ │
│  │  │  │  └────────────────────┘                                     │ │  │ │
│  │  │  │           │                                                  │ │  │ │
│  │  │  │           │ VNet Integration                                │ │  │ │
│  │  │  │           ▼                                                  │ │  │ │
│  │  │  │  ┌────────────────────┐                                     │ │  │ │
│  │  │  │  │  PostgreSQL 17     │                                     │ │  │ │
│  │  │  │  │  Flexible Server   │  ← Database on own cloud resource  │ │  │ │
│  │  │  │  │                    │     Resilient to app updates        │ │  │ │
│  │  │  │  │  Private Endpoint  │                                     │ │  │ │
│  │  │  │  └────────────────────┘                                     │ │  │ │
│  │  │  └─────────────────────────────────────────────────────────────┘ │  │ │
│  │  │                                                                    │  │ │
│  │  │  ┌─────────────────────────────────────────────────────────────┐ │  │ │
│  │  │  │  Container Apps Subnet (10.0.2.0/23)                        │ │  │ │
│  │  │  │                                                              │ │  │ │
│  │  │  │  ┌──────────────────────────────────────────────────────┐  │ │  │ │
│  │  │  │  │     Container Apps Environment                        │  │ │  │ │
│  │  │  │  │                                                        │  │ │  │ │
│  │  │  │  │  ┌──────────────┐         ┌──────────────┐            │  │ │  │ │
│  │  │  │  │  │   API App    │         │ Frontend App │            │  │ │  │ │
│  │  │  │  │  │              │         │              │            │  │ │  │ │
│  │  │  │  │  │  Rails 7.1   │◄────────┤   React      │            │  │ │  │ │
│  │  │  │  │  │  (Docker)    │         │  (Docker)    │            │  │ │  │ │
│  │  │  │  │  │              │         │              │            │  │ │  │ │
│  │  │  │  │  │  Port: 3000  │         │  Port: 80    │            │  │ │  │ │
│  │  │  │  │  │  Replicas:1-3│         │  Replicas:1-3│            │  │ │  │ │
│  │  │  │  │  └──────────────┘         └──────────────┘            │  │ │  │ │
│  │  │  │  │         │                         │                    │  │ │  │ │
│  │  │  │  │         └─────────┬───────────────┘                    │  │ │  │ │
│  │  │  │  │                   │                                    │  │ │  │ │
│  │  │  │  │                   ▼                                    │  │ │  │ │
│  │  │  │  │         ┌──────────────────┐                          │  │ │  │ │
│  │  │  │  │         │  Redis Cache     │                          │  │ │  │ │
│  │  │  │  │         │  (Sidekiq Jobs)  │                          │  │ │  │ │
│  │  │  │  │         └──────────────────┘                          │  │ │  │ │
│  │  │  │  └──────────────────────────────────────────────────────┘  │ │  │ │
│  │  │  └─────────────────────────────────────────────────────────────┘ │  │ │
│  │  └────────────────────────────────────────────────────────────────────┘  │ │
│  │                                                                            │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐    │ │
│  │  │                  Azure Container Registry (ACR)                   │    │ │
│  │  │                                                                    │    │ │
│  │  │  • myregistry.azurecr.io/api:latest                              │    │ │
│  │  │  • myregistry.azurecr.io/frontend:latest                         │    │ │
│  │  └──────────────────────────────────────────────────────────────────┘    │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘

                                      ▲
                                      │
                                      │  HTTPS
                                      │
                          ┌───────────┴───────────┐
                          │                       │
                     ┌────┴────┐           ┌──────┴──────┐
                     │  Users  │           │  Admins     │
                     │         │           │             │
                     │  Web UI │           │  SSH Tunnel │
                     └─────────┘           │  to Bastion │
                                          └─────────────┘
```

## CI/CD Pipeline Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           GitHub Repository                              │
│                                                                          │
│  ┌──────────┐     ┌──────────┐     ┌────────────┐     ┌──────────────┐ │
│  │   API    │     │ Frontend │     │ Terraform  │     │    Puppet    │ │
│  │  (Rails) │     │  (React) │     │ (IaC)      │     │  (Config)    │ │
│  └────┬─────┘     └────┬─────┘     └─────┬──────┘     └──────────────┘ │
│       │                │                  │                             │
└───────┼────────────────┼──────────────────┼─────────────────────────────┘
        │                │                  │
        ▼                ▼                  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       GitHub Actions Workflows                           │
│                                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                  │
│  │   Security   │  │     Test     │  │    Build     │                  │
│  │   Scanning   │  │    (RSpec)   │  │   & Push     │                  │
│  │              │  │              │  │    Docker    │                  │
│  │  • Trivy     │  │  • 50 tests  │  │    Images    │                  │
│  │  • Brakeman  │  │  • Coverage  │  │              │                  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘                  │
│         │                 │                  │                          │
│         └─────────────────┴──────────────────┘                          │
│                           │                                             │
│                           ▼                                             │
│                  ┌──────────────────┐                                   │
│                  │  Terraform Apply │                                   │
│                  │                  │                                   │
│                  │  • Generate      │                                   │
│                  │    tfvars        │                                   │
│                  │  • Deploy Apps   │                                   │
│                  │  • Run           │                                   │
│                  │    Migrations    │                                   │
│                  └────────┬─────────┘                                   │
│                           │                                             │
└───────────────────────────┼─────────────────────────────────────────────┘
                            │
                            ▼
                  ┌──────────────────┐
                  │   Azure Cloud    │
                  │   (Deployed!)    │
                  └──────────────────┘
```

## Network Security

### Access Control

| Component | Public Access | Private Access | Authentication |
|-----------|---------------|----------------|----------------|
| **Frontend** | ✅ HTTPS (Port 443) | - | - |
| **API** | ✅ HTTPS (Port 443) | - | JWT Tokens |
| **Database** | ❌ No | ✅ VNet only | PostgreSQL credentials |
| **Bastion** | ❌ No | ✅ SSH tunnel only | SSH keys |
| **pgAdmin** | ❌ No | ✅ Via bastion only | Web UI login |

### Data Flow

```
User Request → Frontend (HTTPS) → API (HTTPS) → Database (Private)
                                       ↓
                                    Redis Cache

Admin Access → SSH Tunnel → Bastion → pgAdmin → Database
```

## Component Details

### 1. Application Layer (Container Apps)

| Component | Technology | Scaling | Purpose |
|-----------|-----------|---------|---------|
| **API** | Rails 7.1 + Puma | 1-3 replicas | REST API backend |
| **Frontend** | React + Nginx | 1-3 replicas | Web UI |
| **Workers** | Sidekiq | Auto-scale | Background jobs |

### 2. Data Layer

| Component | Technology | Resilience | Backup |
|-----------|-----------|------------|--------|
| **PostgreSQL** | Postgres 17 Flexible | HA enabled | Automated daily |
| **Redis** | Azure Cache | Replicated | - |

### 3. Management Layer

| Component | Technology | Purpose | Access |
|-----------|-----------|---------|--------|
| **Bastion** | Ubuntu 24.04 | Admin access | SSH tunnel |
| **pgAdmin 4** | Web UI | DB management | Via bastion |
| **Puppet** | 8.x | Configuration | Automated |

### 4. CI/CD Layer

| Stage | Tool | Purpose |
|-------|------|---------|
| **Source Control** | GitHub | Version control |
| **CI** | GitHub Actions | Test & build |
| **CD** | Terraform | Deploy infrastructure |
| **Registry** | ACR | Container images |

## Security Features

1. **Network Isolation**
   - Bastion in private subnet (no public IP)
   - Database with private endpoint only
   - Container apps in isolated subnet

2. **Access Control**
   - SSH key authentication for bastion
   - JWT tokens for API
   - Database credentials via secrets

3. **Secrets Management**
   - GitHub Secrets for CI/CD
   - Azure Key Vault integration
   - Environment variables for containers

4. **Automated Updates**
   - CI/CD pipeline for application
   - Terraform for infrastructure
   - Puppet for bastion configuration

## Monitoring & Observability

**Production (Azure):**
```
Application Logs → Container Apps Logs → Azure Log Analytics
                                              │
                                              ├─→ Metrics Dashboard
                                              ├─→ Alerts
                                              └─→ Application Insights
```

**Local Development:**
```
Application → OpenTelemetry Collector → Prometheus
                                    ↓
                                  Tempo (Traces)
                                    ↓
                                Grafana Dashboards
```

See [ADMINISTRATOR_GUIDE.md](ADMINISTRATOR_GUIDE.md#monitoring--alerts) for dashboard screenshots and configuration.

## Disaster Recovery

| Component | RPO | RTO | Strategy |
|-----------|-----|-----|----------|
| **Database** | 5 min | 30 min | Automated backups |
| **Containers** | 0 | 5 min | Immutable deployments |
| **Config** | 0 | 10 min | Infrastructure as Code |

## Compliance

- ✅ **Private network** for sensitive resources
- ✅ **Encrypted** connections (HTTPS, TLS)
- ✅ **Audit logs** for all changes
- ✅ **Automated** configuration management
- ✅ **Version controlled** infrastructure
