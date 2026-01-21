# Architecture Overview

## System Architecture

This document describes the simplified single-VNet architecture for the web application stack.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Azure Cloud Infrastructure                       │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────┐   │
│  │  Resource Group: rg-webapp-dev-weu                             │   │
│  │                                                                 │   │
│  │  ┌───────────────────────────────────────────────────────┐    │   │
│  │  │  Virtual Network: vnet-webapp-dev-weu (10.0.0.0/16)  │    │   │
│  │  │                                                        │    │   │
│  │  │  ┌──────────────────────────────────────────────┐    │    │   │
│  │  │  │  Bastion Subnet (10.0.1.0/24)               │    │    │   │
│  │  │  │                                              │    │    │   │
│  │  │  │  ┌────────────────────────────────┐        │    │    │   │
│  │  │  │  │  Bastion VM                    │        │    │    │   │
│  │  │  │  │  - SSH Access                  │        │    │    │   │
│  │  │  │  │  - Puppet Agent                │        │    │    │   │
│  │  │  │  │  - pgAdmin (Docker)            │        │    │    │   │
│  │  │  │  │  - Admin Users (Puppet)        │        │    │    │   │
│  │  │  │  └────────────────────────────────┘        │    │    │   │
│  │  │  │                                              │    │    │   │
│  │  │  │  Public IP: <dynamic>                       │    │    │   │
│  │  │  └──────────────────────────────────────────────┘    │    │   │
│  │  │                                                        │    │   │
│  │  │  ┌──────────────────────────────────────────────┐    │    │   │
│  │  │  │  Apps Subnet (10.0.2.0/24)                  │    │    │   │
│  │  │  │                                              │    │    │   │
│  │  │  │  ┌────────────────────────────────┐        │    │    │   │
│  │  │  │  │  Container Apps Environment    │        │    │    │   │
│  │  │  │  │  - Rails API Container         │        │    │    │   │
│  │  │  │  │  - Auto-scaling (1-3 replicas) │        │    │    │   │
│  │  │  │  │  - Health checks               │        │    │    │   │
│  │  │  │  └────────────────────────────────┘        │    │    │   │
│  │  │  │                                              │    │    │   │
│  │  │  │  Public Ingress: https://<fqdn>            │    │    │   │
│  │  │  └──────────────────────────────────────────────┘    │    │   │
│  │  │                                                        │    │   │
│  │  │  ┌──────────────────────────────────────────────┐    │    │   │
│  │  │  │  Database Subnet (10.0.3.0/24)              │    │    │   │
│  │  │  │                                              │    │    │   │
│  │  │  │  ┌────────────────────────────────┐        │    │    │   │
│  │  │  │  │  PostgreSQL Flexible Server    │        │    │    │   │
│  │  │  │  │  - Private endpoint            │        │    │    │   │
│  │  │  │  │  - SSL required                │        │    │    │   │
│  │  │  │  │  - Automated backups (7 days)  │        │    │    │   │
│  │  │  │  └────────────────────────────────┘        │    │    │   │
│  │  │  │                                              │    │    │   │
│  │  │  │  Private DNS: privatelink.postgres...       │    │    │   │
│  │  │  └──────────────────────────────────────────────┘    │    │   │
│  │  │                                                        │    │   │
│  │  └────────────────────────────────────────────────────────┘    │   │
│  │                                                                 │   │
│  │  Additional Resources:                                          │   │
│  │  - Log Analytics Workspace (monitoring)                        │   │
│  │  - Network Security Groups (firewall rules)                    │   │
│  │  - Private DNS Zone (database resolution)                      │   │
│  └────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Component Details

### Bastion Host
- **Purpose**: Secure administrative access point
- **OS**: Ubuntu 22.04 LTS
- **Size**: Standard_B2s (2 vCPU, 4GB RAM)
- **Management**: Puppet for configuration
- **Access**: SSH with public key authentication
- **Tools**: pgAdmin4 (Docker container)

### Application Tier
- **Service**: Azure Container Apps
- **Runtime**: Ruby on Rails 7.1 (Puma)
- **Scaling**: Auto-scale 1-3 replicas
- **Container**: Custom Docker image from ACR
- **Health Checks**: HTTP /health endpoint

### Database Tier
- **Service**: Azure PostgreSQL Flexible Server
- **Version**: PostgreSQL 15
- **SKU**: B_Standard_B1ms (Burstable)
- **Storage**: 32GB with auto-grow
- **Backup**: 7-day retention
- **Access**: Private endpoint only

### Networking
- **VNet**: Single 10.0.0.0/16 network
- **Subnets**: 3 isolated subnets
- **NSG**: Security rules on bastion subnet
- **Private DNS**: For PostgreSQL private link

## Security Model

### Network Security
- Bastion subnet: Public SSH (port 22), HTTP/HTTPS for pgAdmin
- Apps subnet: Outbound only, no direct inbound
- Database subnet: Delegated to PostgreSQL, private only

### Access Control
- Bastion: SSH key authentication only
- Database: Username/password + SSL required
- Container Apps: Managed identity (future enhancement)

### Secrets Management
- Terraform: Variables marked sensitive
- GitHub: Stored in GitHub Secrets
- Application: Environment variables

## Deployment Flow

```
Developer → GitHub
    ↓
GitHub Actions
    ↓
┌─────────────────┐
│ Infrastructure  │
│   Pipeline      │ → Terraform → Azure Resources
└─────────────────┘

┌─────────────────┐
│  Application    │
│   Pipeline      │ → Build → ACR → Container Apps
└─────────────────┘

┌─────────────────┐
│     Puppet      │
│   Pipeline      │ → Deploy → Bastion → Apply
└─────────────────┘
```

## Data Flow

```
Internet User
    ↓
Container Apps (HTTPS)
    ↓
Rails Application
    ↓
PostgreSQL (Private, SSL)
    ↓
Data Storage


Admin User
    ↓
SSH to Bastion
    ↓
pgAdmin (HTTP :5050)
    ↓
PostgreSQL (Private, SSL)
```

## Scalability

- **Application**: Auto-scales based on CPU/Memory
- **Database**: Vertical scaling (SKU upgrade)
- **Network**: VNet can expand address space

## Resilience

- **Application**: Multiple replicas, health checks, auto-restart
- **Database**: Automated backups, point-in-time restore
- **Infrastructure**: Terraform state for disaster recovery

## Cost Optimization

- **Burstable SKUs**: For development environment
- **Auto-scaling**: Scale down when idle
- **Shared Resources**: Single VNet, single bastion

## Monitoring

- **Application Logs**: Log Analytics Workspace
- **Metrics**: Container Apps built-in metrics
- **Database**: PostgreSQL query insights
- **Access Logs**: NSG flow logs (optional)

## Future Enhancements

1. **Redis Cache**: Add Azure Cache for Redis
2. **CDN**: Azure Front Door for static assets
3. **Managed Identity**: Replace passwords with MI
4. **Private Link**: For Container Apps ingress
5. **WAF**: Web Application Firewall
6. **Geo-redundancy**: Multi-region deployment
