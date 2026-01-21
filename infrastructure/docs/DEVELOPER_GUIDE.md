# Developer Guide

This guide covers local development, testing, and deployment workflows for application developers.

## 🚀 Local Development Setup

### Prerequisites

- Docker Desktop
- Git
- Ruby 3.2+ (optional, for running outside Docker)
- Node.js 18+ (optional, for frontend development)

### Quick Start

```bash
# Clone repository
git clone <repository-url>
cd revised-task

# Start all services locally
docker-compose up

# Services will be available at:
# - Rails API: http://localhost:3000
# - Frontend: http://localhost:5173
# - PostgreSQL: localhost:5432
# - pgAdmin: http://localhost:5050
```

## 🏃 Running the Application

### With Docker (Recommended)

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f web

# Run rails console
docker-compose exec web rails console

# Run tests
docker-compose exec web rspec

# Stop services
docker-compose down
```

### Without Docker

```bash
# Install dependencies
cd rails-app
bundle install

# Setup database
rails db:create db:migrate db:seed

# Start server
rails server

# In another terminal, start frontend
cd ../frontend
npm install
npm run dev
```

## 🧪 Testing

### Rails Tests

```bash
# Run all tests
docker-compose exec web rspec

# Run specific test file
docker-compose exec web rspec spec/models/user_spec.rb

# Run with coverage
docker-compose exec web rspec --format documentation

# Security scan
docker-compose exec web bundle exec brakeman
```

### Frontend Tests

```bash
# Run Jest tests
cd frontend
npm test

# Run with coverage
npm test -- --coverage
```

## 📝 Development Workflow

### Feature Development

1. **Create a feature branch**:
```bash
git checkout -b feature/my-new-feature
```

2. **Make changes** to the codebase

3. **Test locally**:
```bash
docker-compose up
# Verify changes work
```

4. **Run tests**:
```bash
docker-compose exec web rspec
```

5. **Commit changes**:
```bash
git add .
git commit -m "Add new feature: description"
```

6. **Push to GitHub**:
```bash
git push origin feature/my-new-feature
```

7. **Create Pull Request** on GitHub

8. **CI/CD automatically**:
   - Runs tests
   - Validates code
   - Deploys to staging (if develop branch)
   - Deploys to production (if main branch)

### Database Migrations

```bash
# Create new migration
docker-compose exec web rails generate migration AddFieldToTable field:type

# Run migrations
docker-compose exec web rails db:migrate

# Rollback last migration
docker-compose exec web rails db:rollback

# Check migration status
docker-compose exec web rails db:migrate:status
```

### Adding Dependencies

#### Rails Dependencies

```bash
# Add gem to Gemfile
echo "gem 'new_gem'" >> rails-app/Gemfile

# Install
docker-compose exec web bundle install

# Rebuild image if needed
docker-compose build web
```

#### Frontend Dependencies

```bash
# Add npm package
cd frontend
npm install package-name

# Update Docker image
docker-compose build frontend
```

## 🚢 Deployment

### Automated Deployment (Recommended)

Deployments happen automatically via GitHub Actions:

- **Push to `main`**: Deploys to production
- **Push to `develop`**: Deploys to staging
- **Pull Requests**: Runs tests only

### Manual Deployment

```bash
# Build Docker image
cd rails-app
docker build -t <your-acr>.azurecr.io/rails-api:v1.2.3 .

# Push to Azure Container Registry
docker push <your-acr>.azurecr.io/rails-api:v1.2.3

# Update container app
az containerapp update \
  --name ca-rails-webapp-dev-weu \
  --resource-group rg-webapp-dev-weu \
  --image <your-acr>.azurecr.io/rails-api:v1.2.3

# Run migrations
az containerapp exec \
  --name ca-rails-webapp-dev-weu \
  --resource-group rg-webapp-dev-weu \
  --command "bundle exec rails db:migrate"
```

## 🐛 Debugging

### Rails Debugging

```bash
# Add debugger to code
# Add this line where you want to break:
debugger

# Run with debugger
docker-compose run --service-ports web

# Or use byebug
gem 'byebug'
# Then in code:
byebug
```

### View Application Logs

```bash
# Local
docker-compose logs -f web

# Production
az containerapp logs show \
  --name ca-rails-webapp-dev-weu \
  --resource-group rg-webapp-dev-weu \
  --follow
```

### Database Access

```bash
# Local PostgreSQL
docker-compose exec db psql -U postgres webapp_development

# Production (via pgAdmin)
# Open http://<bastion-ip>:5050
```

## 📋 Common Tasks

### Reset Database

```bash
docker-compose exec web rails db:drop db:create db:migrate db:seed
```

### Generate Scaffold

```bash
docker-compose exec web rails generate scaffold Post title:string content:text
docker-compose exec web rails db:migrate
```

### Rails Console

```bash
# Development
docker-compose exec web rails console

# Production (via bastion)
ssh azureuser@<bastion-ip>
az containerapp exec \
  --name ca-rails-webapp-dev-weu \
  --resource-group rg-webapp-dev-weu \
  --command "bundle exec rails console"
```

## 🎯 Code Style

### Rails

- Follow [Ruby Style Guide](https://rubystyle.guide/)
- Run RuboCop: `docker-compose exec web rubocop`
- Auto-fix: `docker-compose exec web rubocop -a`

### JavaScript/React

- Follow [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- Run ESLint: `cd frontend && npm run lint`
- Auto-fix: `npm run lint:fix`

## 📞 Getting Help

- **Technical Issues**: Open a GitHub issue
- **Questions**: Ask in team Slack channel
- **Documentation**: Check `/docs` folder
