# Terraform Infrastructure

Infrastructure organized for efficient iteration and deployment.

## Structure

```
terraform/
├── modules/                   # Reusable modules (shared)
│   ├── resource_group/        # Azure resource group
│   ├── network/               # VNet, subnets, NSGs
│   ├── bastion/               # Bastion VM with Puppet 8.x
│   ├── postgresql/            # PostgreSQL 17 Flexible Server
│   ├── container_env/         # Container Apps Environment (shared)
│   └── container_app/         # Individual container app (reusable)
│
├── landing_zone/              # Deploy once (foundation + database)
│   ├── main.tf                # Uses ../modules/*
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
│
└── applications/              # Iterate multiple times (container apps)
    ├── main.tf                # Uses ../modules/container_app
    ├── variables.tf
    ├── outputs.tf
    └── terraform.tfvars.example
```

## Deployment Order

### 1. Deploy Landing Zone (Once)

The landing zone includes everything:
- Resource Group
- Network (VNet + Subnets)
- Bastion VM
- PostgreSQL Database
- Container Apps Environment

```bash
cd landing_zone
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars
export TF_VAR_bastion_admin_ssh_key="$(cat ~/.ssh/id_rsa.pub)"
export TF_VAR_db_admin_password="SecurePassword123!"
terraform init
terraform apply
```

**Save outputs:**
```bash
terraform output resource_group_name
terraform output container_environment_id
terraform output postgresql_connection_string
```

### 2. Deploy Applications (Iterate)

Deploy container apps using the landing zone infrastructure.

You can iterate this layer multiple times for different apps:
- First iteration: Rails API
- Second iteration: Sidekiq worker
- Third iteration: React frontend
- etc.

```bash
cd ../applications
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with landing zone outputs
export TF_VAR_database_url="<from landing zone>"
terraform init
terraform apply
```

## Why This Structure?

**Benefits:**
1. **Iteration-Friendly**: Applications layer can be deployed multiple times
2. **Shared Modules**: All modules in one place (`modules/`)
3. **Separation of Concerns**: Landing zone (stable) vs applications (frequently changing)
4. **Reusable**: `container_app` module can be instantiated multiple times

## Module Pattern

Each module follows this structure:
```
module_name/
├── label.tf       # CloudPosse label definitions
├── main.tf        # Resource definitions
├── variables.tf   # Input variables
└── outputs.tf     # Output values
```

## Version Requirements

- Terraform >= 1.14.0
- Azure Provider ~> 4.57
- PostgreSQL 17
- Ubuntu 24.04 LTS
- Puppet 8.x

## Next Steps

1. Deploy landing zone
2. Deploy Rails API (first iteration of applications)
3. Deploy additional apps (subsequent iterations of applications)
4. Access bastion for database administration
