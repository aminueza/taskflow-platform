# pgAdmin Module

## Overview

This Puppet module installs and configures pgAdmin 4 in server mode using Docker. It provides a web-based PostgreSQL administration interface with pre-configured database connections, health monitoring, and security hardening.

## Features

- **Docker-based deployment** for easy management and isolation
- **Pre-configured database connections** via servers.json
- **Automatic health checks** with auto-restart on failure
- **Firewall rules** for network access control
- **Systemd integration** for service management
- **Azure Key Vault integration** for credential management

## Requirements

- Docker must be installed and running
- The `garethr/docker` module (for `docker::run` resource)
- The `puppetlabs/stdlib` module
- The `camptocamp/systemd` module

## Usage

### Basic Usage

```puppet
class { 'pgadmin':
  email    => 'admin@example.com',
  password => Sensitive('SecurePassword123!'),
  port     => 8080,
}
```

### With Pre-configured Database Servers

```puppet
class { 'pgadmin':
  email              => 'admin@devops.local',
  password           => Sensitive('admin'),
  port               => 5050,
  server_connections => {
    'production' => {
      'host'     => 'prod-db.postgres.database.azure.com',
      'port'     => 5432,
      'database' => 'webapp_db',
      'username' => 'dbadmin',
      'ssl_mode' => 'require',
      'comment'  => 'Production database',
    },
    'local' => {
      'host'     => 'postgres',
      'port'     => 5432,
      'database' => 'webapp_development',
      'username' => 'postgres',
      'ssl_mode' => 'prefer',
      'comment'  => 'Local development database',
    },
  },
}
```

### Via Profile (Recommended)

The module is designed to be used via the `profile::bastion::dbtools` profile:

```puppet
include profile::bastion
```

This automatically includes pgAdmin with configuration from Hiera.

## Parameters

### `version`
- **Type:** String
- **Default:** `'latest'`
- **Description:** pgAdmin Docker image version tag

### `port`
- **Type:** Integer
- **Default:** `8080`
- **Description:** Port for pgAdmin web interface (mapped to container port 80)

### `email`
- **Type:** String
- **Default:** `'admin@example.com'`
- **Description:** Default admin email for pgAdmin login

### `password`
- **Type:** Sensitive[String]
- **Default:** `Sensitive('changeme')`
- **Description:** Default admin password for pgAdmin login (use eyaml in production)

### `server_connections`
- **Type:** Hash
- **Default:** `{}`
- **Description:** Hash of PostgreSQL server connections to pre-configure
- **Format:**
  ```yaml
  server_name:
    host: 'hostname'
    port: 5432
    database: 'dbname'
    username: 'username'
    ssl_mode: 'require'  # prefer, require, verify-ca, verify-full
    comment: 'description'
  ```

### `data_dir`
- **Type:** String
- **Default:** `'/var/lib/pgadmin'`
- **Description:** Directory for pgAdmin data persistence

### `enable_ssl`
- **Type:** Boolean
- **Default:** `false`
- **Description:** Whether to enable SSL for pgAdmin (typically handled by Azure LB)

### `allowed_hosts`
- **Type:** Array[String]
- **Default:** `['10.0.0.0/8']`
- **Description:** Array of allowed host IPs/networks for firewall rules

## Hiera Configuration

### Example Hiera Data

```yaml
# pgAdmin web interface configuration
bastion::pgadmin::email: 'admin@devops.local'
bastion::pgadmin::password: >
  ENC[PKCS7,MIIBiQYJKoZ...] # Use eyaml for encryption
bastion::pgadmin::port: 5050

# Pre-configured database servers
bastion::database_servers:
  production:
    host: 'prod-psql.postgres.database.azure.com'
    port: 5432
    database: 'webapp_db'
    username: 'dbadmin'
    ssl_mode: 'require'
    comment: 'Production database - handle with care'

  staging:
    host: 'staging-psql.postgres.database.azure.com'
    port: 5432
    database: 'webapp_db'
    username: 'dbadmin'
    ssl_mode: 'require'
    comment: 'Staging database'

  local:
    host: 'postgres'
    port: 5432
    database: 'webapp_development'
    username: 'postgres'
    ssl_mode: 'prefer'
    comment: 'Local development database (Docker)'
```

## Files and Directories

### Created by Module

- `/var/lib/pgadmin/` - Data directory (persistent storage)
- `/var/lib/pgadmin/config/` - Configuration directory
- `/var/lib/pgadmin/servers.json` - Pre-configured server connections
- `/usr/local/bin/pgadmin-healthcheck.sh` - Health check script

### Systemd Service

The module creates a systemd service: `docker-pgadmin.service`

**Management commands:**
```bash
# Check status
systemctl status docker-pgadmin

# Restart service
systemctl restart docker-pgadmin

# View logs
journalctl -u docker-pgadmin -f
```

## Health Checks

The module installs a health check script that:
- Runs every 5 minutes via cron
- Tests the `/misc/ping` endpoint
- Automatically restarts pgAdmin on failure (after 3 retries)
- Logs all checks to syslog

**Manual health check:**
```bash
/usr/local/bin/pgadmin-healthcheck.sh
```

## Security Considerations

1. **Password Management**: Use eyaml to encrypt passwords in Hiera
2. **Network Access**: Configure `allowed_hosts` to restrict access
3. **SSL/TLS**: Enable SSL or use Azure Application Gateway for TLS termination
4. **Database Passwords**: Store in Azure Key Vault, not in pgAdmin
5. **Firewall**: UFW rules are automatically configured

## Accessing pgAdmin

After deployment, access pgAdmin at:
- **URL:** `http://<bastion-ip>:<port>`
- **Default:** `http://10.0.1.10:5050` (or port 8080)
- **Login:** Use email and password from Hiera configuration

## Integration with Azure

### Azure Key Vault

Database credentials should be stored in Azure Key Vault. Use the bastion's managed identity to retrieve them:

```bash
# Retrieve credentials (available on bastion host)
/usr/local/bin/get-db-credentials.sh <keyvault-name>
```

### Network Architecture

In hub-and-spoke topology:
- pgAdmin runs on bastion host in hub VNet
- Connects to PostgreSQL in spoke VNets via VNet peering
- Access controlled by NSGs and UFW

## Troubleshooting

### pgAdmin not starting

```bash
# Check Docker container status
docker ps -a | grep pgadmin

# View container logs
docker logs pgadmin

# Check systemd service
systemctl status docker-pgadmin
```

### Cannot connect to database

1. Verify network connectivity:
   ```bash
   telnet <db-host> 5432
   ```

2. Check NSG rules in Azure
3. Verify database firewall rules allow bastion IP
4. Check VNet peering configuration

### Health check failures

```bash
# Check last health check
grep pgadmin-healthcheck /var/log/syslog

# Manual test
curl http://localhost:<port>/misc/ping
```

## Development and Testing

### Testing Locally

The module can be tested locally using Docker Compose:

```bash
cd /path/to/azure-devops-challenge
docker-compose up -d pgadmin
```

Access at: `http://localhost:5050`

### Puppet Development Kit (PDK)

```bash
# Validate syntax
pdk validate

# Run unit tests
pdk test unit

# Run acceptance tests
pdk bundle exec rake acceptance
```

## Author

DevOps Task - Azure Infrastructure Team

## License

Proprietary - Internal Use Only
