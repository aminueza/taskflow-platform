# Administrator Guide

This guide covers operational tasks for administrators managing the Azure infrastructure and bastion host.

## 🔑 Accessing the Bastion Host

The bastion host is the single entry point for administrative access to the infrastructure.

### SSH Access

```bash
# Get bastion IP from Terraform
cd infrastructure/terraform
bastion_ip=$(terraform output -raw bastion_public_ip)

# SSH to bastion
ssh azureuser@$bastion_ip

# Or with specific key
ssh -i ~/.ssh/id_ed25519 azureuser@$bastion_ip
```

### Managing Admin Users

Admin users are managed via Puppet. To add/remove users:

1. Edit `puppet/data/common.yaml`:

```yaml
bastion_users::users:
  newuser:
    uid: 2003
    groups:
      - sudo
    ssh_keys:
      - 'ssh-ed25519 AAAAC3... user@example.com'
```

2. Apply the configuration:

```bash
# On bastion host
sudo puppet apply /etc/puppetlabs/code/manifests/site.pp

# Or via CI/CD
git add puppet/data/common.yaml
git commit -m "Add new admin user"
git push origin main
```

## 🗄️ Database Management with pgAdmin

pgAdmin runs on the bastion host at `http://<bastion-ip>:5050`.

### Initial Access

```
URL: http://<bastion-ip>:5050
Email: admin@example.com
Password: admin (change this!)
```

### Connecting to PostgreSQL

The PostgreSQL server is pre-configured in pgAdmin:

- **Host**: `psql-webapp-dev-weu.postgres.database.azure.com`
- **Port**: 5432
- **Username**: `psqladmin`
- **Database**: `webapp_production`
- **SSL Mode**: Require

### Common Database Operations

#### View Active Connections
```sql
SELECT * FROM pg_stat_activity;
```

#### Create Backup
```bash
# From bastion host
pg_dump -h psql-webapp-dev-weu.postgres.database.azure.com \
  -U psqladmin \
  -d webapp_production \
  -f backup_$(date +%Y%m%d).sql
```

#### Restore Backup
```bash
psql -h psql-webapp-dev-weu.postgres.database.azure.com \
  -U psqladmin \
  -d webapp_production \
  -f backup_20260119.sql
```

## 📊 Monitoring

### Check Application Health

```bash
# Get container app URL
app_url=$(cd infrastructure/terraform && terraform output -raw container_app_url)

# Health check
curl $app_url/health
```

### View Application Logs

```bash
# Via Azure CLI
az containerapp logs show \
  --name ca-rails-webapp-dev-weu \
  --resource-group rg-webapp-dev-weu \
  --follow

# Or in Azure Portal
# Navigate to: Container Apps > ca-rails-webapp-dev-weu > Logs
```

### Database Performance

Access in pgAdmin:
```sql
-- Top 10 slowest queries
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Database size
SELECT pg_size_pretty(pg_database_size('webapp_production'));
```

## 🔄 Deployment Operations

### Manual Application Deployment

```bash
# Update container app to new image
az containerapp update \
  --name ca-rails-webapp-dev-weu \
  --resource-group rg-webapp-dev-weu \
  --image <acr>.azurecr.io/rails-api:v1.2.3

# Run database migrations
az containerapp exec \
  --name ca-rails-webapp-dev-weu \
  --resource-group rg-webapp-dev-weu \
  --command "bundle exec rails db:migrate"
```

### Infrastructure Updates

```bash
# Review planned changes
cd infrastructure/terraform
terraform plan

# Apply changes
terraform apply

# View current state
terraform show
```

## 🚨 Troubleshooting

### Application Not Responding

1. Check container app status:
```bash
az containerapp show \
  --name ca-rails-webapp-dev-weu \
  --resource-group rg-webapp-dev-weu \
  --query "properties.runningStatus"
```

2. View recent logs:
```bash
az containerapp logs show \
  --name ca-rails-webapp-dev-weu \
  --resource-group rg-webapp-dev-weu \
  --tail 100
```

3. Restart the app:
```bash
az containerapp revision restart \
  --name ca-rails-webapp-dev-weu \
  --resource-group rg-webapp-dev-weu
```

### Database Connection Issues

1. Verify PostgreSQL is running:
```bash
az postgres flexible-server show \
  --name psql-webapp-dev-weu \
  --resource-group rg-webapp-dev-weu \
  --query "state"
```

2. Check firewall rules:
```bash
az postgres flexible-server firewall-rule list \
  --name psql-webapp-dev-weu \
  --resource-group rg-webapp-dev-weu
```

3. Test connection from bastion:
```bash
psql -h psql-webapp-dev-weu.postgres.database.azure.com \
  -U psqladmin \
  -d webapp_production
```

### Puppet Configuration Not Applying

1. Test Puppet syntax:
```bash
puppet parser validate /etc/puppetlabs/code/manifests/site.pp
```

2. Dry run:
```bash
sudo puppet apply --noop /etc/puppetlabs/code/manifests/site.pp
```

3. Apply with verbose output:
```bash
sudo puppet apply --verbose /etc/puppetlabs/code/manifests/site.pp
```

## 🔐 Security Best Practices

1. **Rotate Credentials**: Change default passwords immediately
2. **SSH Keys Only**: Disable password authentication
3. **Audit Logs**: Review regularly
4. **Least Privilege**: Grant minimum required permissions
5. **Updates**: Keep bastion host OS and packages updated

## 📞 Emergency Contacts

- **Infrastructure Issues**: devops@example.com
- **Database Issues**: dba@example.com
- **Security Issues**: security@example.com
