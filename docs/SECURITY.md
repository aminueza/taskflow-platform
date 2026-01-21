# Security Model

## Threat Model

| Threat | Mitigation |
|--------|------------|
| **Credential theft from CI/CD** | OIDC federated identity - no long-lived secrets stored |
| **Database exposure** | Private endpoint, no public IP, VNet-only access |
| **Lateral movement** | Network segmentation, least privilege RBAC |
| **Secret leakage in code** | Gitleaks scanning, secrets in Key Vault only |
| **Container vulnerabilities** | Trivy scanning on every build |
| **Application vulnerabilities** | Brakeman (SAST) for Rails, dependency audits |
| **Unauthorized admin access** | SSH via Azure Bastion tunnel only, no public bastion IP |
| **Man-in-the-middle** | TLS everywhere, HTTPS-only ingress |

## Authentication & Authorization

### CI/CD: Federated Identity (OIDC)

No stored credentials in GitHub. Uses OpenID Connect for Azure authentication:

```yaml
# .github/workflows - No secrets stored, identity federation
- uses: azure/login@v2
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

**Why it matters**: Tokens are short-lived, scoped to specific repos/branches, and can't be leaked or reused.

### Least Privilege Access

| Identity | Scope | Permissions |
|----------|-------|-------------|
| GitHub Actions (Infra) | Resource Group | Contributor |
| GitHub Actions (Apps) | Container Apps, ACR | AcrPush, Container App Contributor |
| Container Apps | ACR | AcrPull (managed identity) |
| Bastion VM | Key Vault | Secrets Reader |

No admin credentials stored. Each component has only the permissions it needs.

## Network Security

### Private by Default

```
Internet ─── HTTPS ──→ [Container Apps] ──→ [PostgreSQL]
                              │                   │
                              │          (Private Endpoint)
                              │                   │
                        [VNet 10.0.0.0/16] ───────┘
                              │
                     [Bastion VM] ←── SSH Tunnel ←── Admin
```

| Resource | Public Access | Network |
|----------|---------------|---------|
| Frontend | ✅ HTTPS only | Container Apps ingress |
| API | ✅ HTTPS only | Container Apps ingress |
| PostgreSQL | ❌ None | Private endpoint, VNet only |
| Key Vault | ❌ None | Service endpoints, VNet only |
| Bastion VM | ❌ None | Azure Bastion tunnel |

### No Public Database

Database is only accessible via:
1. Container Apps (same VNet)
2. Bastion VM → pgAdmin (SSH tunnel)

Zero public IP exposure for sensitive resources.

## Secrets Management

### Azure Key Vault

All secrets stored in Key Vault with:
- VNet service endpoints (no public access)
- RBAC-based access control
- Audit logging enabled

### Application Secrets

| Secret | Storage | Rotation |
|--------|---------|----------|
| Database credentials | Key Vault | Manual |
| API keys | Key Vault | Manual |
| SSH keys | Key Vault | On bastion rebuild |
| OIDC tokens | Azure AD | Automatic (short-lived) |

## Infrastructure as Code

All infrastructure is:
- **Version controlled** in Git
- **Reviewed** via pull requests
- **Immutable** - no manual changes in Azure portal
- **Auditable** - Terraform state tracks all changes

## Compliance Checklist

- ✅ No long-lived credentials in CI/CD
- ✅ Database isolated in private network
- ✅ Encrypted connections (TLS everywhere)
- ✅ Least privilege for all identities
- ✅ Secrets in Key Vault, not in code
- ✅ Audit logs for infrastructure changes
- ✅ Security scanning in pipeline (Trivy, Brakeman)

