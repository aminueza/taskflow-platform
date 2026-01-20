#!/bin/bash
set -e

echo "🚀 Starting Web Application Stack..."
echo ""

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

if [ ! -f .env ]; then
    echo "🔐 No .env file found. Generating secrets..."
    mkdir -p scripts
    if [ -f scripts/generate-secrets.sh ]; then
        bash scripts/generate-secrets.sh
    else
        echo "⚠️  Warning: scripts/generate-secrets.sh not found. Creating basic .env..."
        cat > .env <<EOF
POSTGRES_DB=webapp_development
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
RAILS_ENV=development
SECRET_KEY_BASE=dev_secret_key_base_change_in_production
DATABASE_URL=postgresql://postgres:postgres@postgres:5432/webapp_development
PGADMIN_DEFAULT_EMAIL=admin@example.com
PGADMIN_DEFAULT_PASSWORD=admin
VITE_API_URL=http://localhost:3000
COMPOSE_PROJECT_NAME=webapp-stack
EOF
        chmod 600 .env
    fi
    echo ""
else
    echo "✅ Using existing .env file"
fi

echo "📦 Starting Docker services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

echo "🗄️  Setting up database..."
docker-compose exec -T web bundle exec rails db:create db:migrate db:seed 2>/dev/null || echo "Database already exists"

echo ""
echo "✅ Setup complete!"
echo ""
echo "📝 Services are running at:"
echo "   - Rails API:  http://localhost:3000"
echo "   - Frontend:   http://localhost:5173"
echo "   - pgAdmin:    http://localhost:5050"
echo "   - PostgreSQL: localhost:5432"
echo ""
echo "📚 Useful commands:"
echo "   - View logs:          docker-compose logs -f"
echo "   - Rails console:      docker-compose exec web rails console"
echo "   - Run tests:          docker-compose exec web rspec"
echo "   - Stop services:      docker-compose down"
echo ""
