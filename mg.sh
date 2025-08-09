# scripts/deploy-user.sh
#!/bin/bash

HEADSCALE_HOME="${HEADSCALE_HOME:-$HOME/tail-headscale}"
cd "$HEADSCALE_HOME"

echo "🚀 Deploying Headscale from user directory: $HEADSCALE_HOME"

# Load environment
source .env

# Create data directories
mkdir -p database/{data,backup}
mkdir -p {traefik/letsencrypt,headscale/data,headplane/data,authelia/data}

# Set proper permissions
chmod 755 database/data database/backup
chmod 755 traefik/letsencrypt headscale/data headplane/data authelia/data

# Deploy services in order
echo "📦 Deploying Traefik..."
cd traefik && docker-compose up -d && sleep 10

echo "📊 Deploying Database..."
cd ../database && docker-compose up -d && sleep 30

echo "🔐 Deploying Authelia..."
cd ../authelia && docker-compose up -d && sleep 20

echo "🌐 Deploying Headscale..."
cd ../headscale && docker-compose up -d && sleep 20

echo "🎨 Deploying Headplane..."
cd ../headplane && docker-compose up -d && sleep 15

echo "📈 Deploying Monitoring..."
cd ../monitoring && docker-compose up -d

cd "$HEADSCALE_HOME"
echo "✅ Deployment completed!"