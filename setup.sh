#!/bin/bash

# Gophish + Caddy Docker Setup Helper Script
# Usage: bash setup.sh

set -e

echo "🚀 Gophish + Caddy Docker Setup"
echo "================================"
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Docker and Docker Compose found"
echo ""

# Read domain
echo "What domain will you use for the phishing page?"
echo "Example: phish.example.com"
read -p "Domain: " DOMAIN

if [ -z "$DOMAIN" ]; then
    echo "❌ Domain cannot be empty"
    exit 1
fi

# Update Caddyfile
echo ""
echo "Updating Caddyfile with domain: $DOMAIN"
sed -i "s/phish.example.com/$DOMAIN/g" caddy/Caddyfile

# Start containers
echo ""
echo "Starting Docker containers..."
docker-compose up -d

# Wait for services
echo ""
echo "Waiting for services to start..."
sleep 5

# Show status
echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Access Gophish Admin: https://localhost:3333"
echo "   Default: admin / gophish"
echo ""
echo "2. Update your DNS records:"
echo "   $DOMAIN  A  YOUR_THINKSTATION_IP"
echo ""
echo "3. Configure SMTP and create campaigns"
echo ""
echo "4. Landing page will be served at: https://$DOMAIN"
echo ""
echo "📊 Useful commands:"
echo "   docker-compose logs -f                  # View all logs"
echo "   docker-compose logs -f gophish         # View Gophish logs"
echo "   docker-compose logs -f caddy           # View Caddy logs"
echo "   docker-compose down                    # Stop services"
echo "   docker-compose restart                 # Restart services"
echo ""
