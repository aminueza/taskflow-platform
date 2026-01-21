# TaskFlow Platform - Developer Usage Guide

## Table of Contents

1. [Getting Started](#getting-started)
2. [Local Development](#local-development)
3. [Development Workflow](#development-workflow)
4. [Testing](#testing)
5. [Deployment Process](#deployment-process)
6. [Troubleshooting](#troubleshooting)

---

## Getting Started

### Prerequisites

- **Git** (version control)
- **Docker** & Docker Compose (local development)
- **Ruby 3.2+** (for API development)
- **Node.js 18+** (for frontend development)
- **PostgreSQL 15+** (local database)

### Key Files

**Dockerfiles:**
- `api/Dockerfile` - Rails container
- `frontend/Dockerfile` - React container

**Infrastructure:**
- `infrastructure/terraform/modules/bastion/` - No public IP
- `infrastructure/terraform/modules/postgresql/` - Separate database

**Puppet:**
- `puppet/modules/bastion_users/` - User management
- `puppet/modules/pgadmin/` - Database tool

**CI/CD:**
- `.github/workflows/application.yml` - App pipeline
- `.github/workflows/infrastructure.yml` - Terraform
- `.github/workflows/puppet.yml` - Config management

**Scripts:**
- `scripts/generate-secrets.sh` - Create .env
- `scripts/quick-start.sh` - Start local stack
- `scripts/tunnel.sh` - Bastion access

### Repository Structure

```
taskflow-platform/
├── api/                    # Rails API backend
│   ├── app/               # Application code
│   ├── spec/              # RSpec tests
│   ├── Dockerfile         # API container definition
│   └── Gemfile            # Ruby dependencies
├── frontend/              # React frontend
│   ├── src/               # Source code
│   ├── public/            # Static assets
│   ├── Dockerfile         # Frontend container definition
│   └── package.json       # Node dependencies
├── infrastructure/        # Infrastructure as Code
│   └── terraform/         # Terraform configurations
├── puppet/                # Puppet configuration management
├── observability/         # Monitoring stack (local dev)
│   ├── otel-collector.yaml    # OpenTelemetry config
│   ├── prometheus.yml         # Metrics collection
│   ├── tempo.yaml             # Distributed tracing
│   └── grafana/               # Dashboards
├── scripts/               # Helper scripts
│   ├── generate-secrets.sh    # Create .env file
│   ├── quick-start.sh         # Start local stack
│   └── tunnel.sh              # Bastion proxy
└── docs/                  # Documentation
```

---

## Local Development

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/taskflow-platform.git
cd taskflow-platform
```

### 2. Setup API (Rails Backend)

```bash
cd api

# Install dependencies
bundle install

# Setup database
cp config/database.yml.example config/database.yml
bundle exec rails db:create db:migrate db:seed

# Start server
bundle exec rails server
```

**API will be available at:** `http://localhost:3000`

### 3. Setup Frontend (React)

```bash
cd frontend

# Install dependencies
npm install

# Configure API endpoint
cp .env.example .env
# Edit .env and set REACT_APP_API_URL=http://localhost:3000

# Start development server
npm start
```

**Frontend will be available at:** `http://localhost:3001`

### 4. Using Docker Compose (Recommended)

#### Quick Start

```bash
# 1. Generate secrets
./scripts/generate-secrets.sh

# 2. Start everything
./scripts/quick-start.sh
```

The generate script creates:
- Database credentials
- Rails secret keys
- Redis password
- pgAdmin credentials

The quick-start script:
- Starts docker-compose
- Creates and migrates database
- Seeds initial data

#### Manual Control

```bash
# Start services
docker-compose up

# Run in detached mode
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

**Services:**
- Frontend: http://localhost:5173
- API: http://localhost:3000
- pgAdmin: http://localhost:5050
- Grafana: http://localhost:3030
- Prometheus: http://localhost:9090
- PostgreSQL: localhost:5432
- Redis: localhost:6379

**Credentials:** Check `.env` file for generated passwords

**Observability:**
- Grafana dashboards (auto-loaded):
  - Rails Application Dashboard - users, tasks, database, Redis, Sidekiq
  - SLO/SLI Dashboard - availability, error rate, latency metrics
- Prometheus collects metrics from Rails, PostgreSQL, Redis
- Tempo stores distributed traces
- OpenTelemetry Collector processes telemetry data

Dashboards are in `observability/grafana/dashboards/` and loaded automatically on startup.

---


## Testing

### API Tests (RSpec)

```bash
cd api

# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec

# Run specific test line
bundle exec rspec spec/models/user_spec.rb:10
```

**Test Structure:**
```
spec/
├── models/          # Model tests
├── requests/        # API endpoint tests
├── services/        # Service object tests
├── workers/         # Background job tests
└── factories/       # Test data factories
```

### Frontend Tests (Jest)

```bash
cd frontend

# Run all tests
npm test

# Run with coverage
npm test -- --coverage

# Run specific test
npm test -- UserComponent.test.js

# Watch mode
npm test -- --watch
```

### Integration Tests

```bash
# Run full integration test suite
docker-compose -f docker-compose.test.yml up --abort-on-container-exit
```

---

## Deployment Process

### Automatic Deployment (Recommended)

Deployments are **fully automated** via GitHub Actions:

1. **Push to `main` branch**
   ```bash
   git push origin main
   ```

2. **CI/CD Pipeline Executes:**
   ```
   Security Scan → Tests → Build → Deploy → Migrate
   ```

3. **Monitor Deployment:**
   - Go to GitHub Actions tab
   - View workflow run
   - Check deployment summary

### What Gets Deployed

When you push to `main`:

✅ **API Container** - Latest API code
✅ **Frontend Container** - Latest frontend build
✅ **Database Migrations** - Automatic migration
✅ **Environment Variables** - Updated from secrets

### Deployment Stages

```yaml
1. Security Scan (Trivy, Brakeman)
   ↓
2. Run Tests (RSpec, Coverage)
   ↓
3. Build Docker Images
   ↓
4. Push to Azure Container Registry
   ↓
5. Deploy via Terraform
   ↓
6. Run Database Migrations
   ↓
7. Health Check
```

### Manual Deployment

If you need to deploy manually:

```bash
# Build images locally
docker build -t taskflow-api ./api
docker build -t taskflow-frontend ./frontend

# Tag for registry
docker tag taskflow-api myregistry.azurecr.io/api:latest
docker tag taskflow-frontend myregistry.azurecr.io/frontend:latest

# Push to registry
docker push myregistry.azurecr.io/api:latest
docker push myregistry.azurecr.io/frontend:latest

# Deploy with Terraform (uses remote state in Azure Storage Account)
cd infrastructure/terraform/applications
terraform apply
```

### Infrastructure Management

Terraform state is stored remotely in Azure Storage Account for team collaboration and state locking.

```bash
# View current state
terraform show

# Plan changes
terraform plan

# Apply changes
terraform apply

# View outputs
terraform output
```

---

## Environment Variables

### API Environment Variables

```bash
# Required
DATABASE_URL=postgresql://user:pass@host:5432/dbname
REDIS_URL=redis://localhost:6379/0
SECRET_KEY_BASE=your-secret-key-base

# Optional
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
```

### Frontend Environment Variables

```bash
# Required
REACT_APP_API_URL=https://api.example.com

# Optional
NODE_ENV=production
REACT_APP_ENABLE_ANALYTICS=true
```

### Setting Secrets in GitHub

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add required secrets:
   - `DATABASE_URL`
   - `REDIS_URL`
   - `SECRET_KEY_BASE`
   - `API_URL`
   - `ACR_LOGIN_SERVER`
   - `ACR_USERNAME`
   - `ACR_PASSWORD`
   - Azure credentials

---

## Database Management

### Running Migrations

Migrations run **automatically** during deployment.

For manual migration:

```bash
# Local
bundle exec rails db:migrate

# Production (via Azure CLI)
az containerapp exec \
  --name ca-api-dev-weu \
  --resource-group rg-taskflow-dev-weu \
  --command "bundle exec rails db:migrate"
```

### Creating Migrations

```bash
# Generate migration
rails generate migration AddColumnToTable column:type

# Edit migration file
# db/migrate/YYYYMMDDHHMMSS_add_column_to_table.rb

# Run migration locally
bundle exec rails db:migrate

# Rollback if needed
bundle exec rails db:rollback
```

### Seeding Data

```bash
# Local
bundle exec rails db:seed

# Production (use with caution!)
bundle exec rails db:seed RAILS_ENV=production
```

---

## Debugging

### View Application Logs

```bash
# Via Azure CLI
az containerapp logs show \
  --name ca-api-dev-weu \
  --resource-group rg-taskflow-dev-weu \
  --follow

# Via GitHub Actions
# Check "Deployment Summary" in Actions tab
```

### Access Rails Console (Production)

```bash
az containerapp exec \
  --name ca-api-dev-weu \
  --resource-group rg-taskflow-dev-weu \
  --command "bundle exec rails console"
```

### Common Issues

#### Build Fails

**Problem:** Docker build fails
**Solution:**
```bash
# Clear Docker cache
docker system prune -a

# Rebuild without cache
docker build --no-cache -t taskflow-api ./api
```

#### Tests Fail Locally

**Problem:** Tests pass in CI but fail locally
**Solution:**
```bash
# Reset database
bundle exec rails db:drop db:create db:migrate

# Clear test cache
bundle exec rails tmp:clear

# Run tests again
bundle exec rspec
```

#### Database Connection Error

**Problem:** Can't connect to PostgreSQL
**Solution:**
```bash
# Check PostgreSQL is running
docker-compose ps

# Restart database
docker-compose restart postgres

# Verify connection
psql -h localhost -U postgres -d taskflow_development
```

---

## Code Style & Linting

### Ruby (RuboCop)

```bash
cd api

# Check style
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -A

# Check specific file
bundle exec rubocop app/models/user.rb
```

### JavaScript (ESLint)

```bash
cd frontend

# Check style
npm run lint

# Auto-fix issues
npm run lint:fix
```
---


## Quick Reference

### Common Commands

```bash
# Start local development
docker-compose up

# Run tests
cd api && bundle exec rspec
cd frontend && npm test

# Deploy to production
git push origin main

# View logs
az containerapp logs show --name ca-api-dev-weu --follow

# Database migration
bundle exec rails db:migrate

# Rails console
bundle exec rails console

# Build Docker image
docker build -t taskflow-api ./api
```