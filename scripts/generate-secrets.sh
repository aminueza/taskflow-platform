#!/bin/bash
set -e

echo "🔐 Generating environment secrets..."

# Generate random secret keys
generate_secret() {
    openssl rand -hex 32
}

generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

# Create .env file
cat > .env <<EOF
# ============================================================================
# AUTO-GENERATED SECRETS - DO NOT COMMIT TO GIT
# Generated at: $(date)
# ============================================================================

# Database Configuration
POSTGRES_DB=webapp_development
POSTGRES_USER=postgres
POSTGRES_PASSWORD=$(generate_password)

# Rails Configuration
RAILS_ENV=development
RAILS_MASTER_KEY=$(generate_secret)
SECRET_KEY_BASE=$(generate_secret)

# Redis Configuration
REDIS_PASSWORD=$(generate_password)
REDIS_URL=redis://:$(generate_password)@redis:6379/0

# Database URLs
DATABASE_URL=postgresql://postgres:$(generate_password)@postgres:5432/webapp_development
TEST_DATABASE_URL=postgresql://postgres:$(generate_password)@postgres:5432/webapp_test

# pgAdmin Configuration
PGADMIN_DEFAULT_EMAIL=admin@example.com
PGADMIN_DEFAULT_PASSWORD=$(generate_password)

# Grafana Configuration
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=$(generate_password)

# Frontend Configuration
VITE_API_URL=http://localhost:3000

# Docker Compose Project
COMPOSE_PROJECT_NAME=webapp-stack
EOF

# Make the file read-only to prevent accidental modification
chmod 600 .env

echo "✅ Secrets generated successfully!"
echo ""
echo "📝 Generated credentials:"
echo "   PostgreSQL:"
echo "     - User: postgres"
echo "     - Password: (see .env file)"
echo "     - Database: webapp_development"
echo ""
echo "   pgAdmin:"
echo "     - URL: http://localhost:5050"
echo "     - Email: admin@example.com"
echo "     - Password: (see .env file - PGADMIN_DEFAULT_PASSWORD)"
echo ""
echo "   Grafana:"
echo "     - URL: http://localhost:3030"
echo "     - User: admin"
echo "     - Password: (see .env file - GRAFANA_ADMIN_PASSWORD)"
echo ""
echo "⚠️  IMPORTANT: .env file has been created with sensitive data"
echo "   - DO NOT commit this file to git (already in .gitignore)"
echo "   - File permissions set to 600 (owner read/write only)"
echo ""
