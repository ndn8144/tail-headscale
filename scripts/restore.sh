#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <backup_date>"
    echo "Example: $0 20241215_143022"
    echo ""
    echo "Available backups:"
    ls -la /backup/headscale/ 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_DATE="$1"
BACKUP_PATH="/backup/headscale/$BACKUP_DATE"

if [ ! -d "$BACKUP_PATH" ]; then
    echo "❌ Backup not found: $BACKUP_PATH"
    exit 1
fi

echo "🔄 Starting Headscale restore from: $BACKUP_DATE"
echo "⚠️  WARNING: This will overwrite current data!"
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Restore cancelled"
    exit 1
fi

# Stop all services
echo "⏹️ Stopping services..."
cd /opt/headscale
docker-compose -f traefik/docker-compose.yml down
docker-compose -f database/docker-compose.yml down
docker-compose -f authelia/docker-compose.yml down
docker-compose -f headscale/docker-compose.yml down
docker-compose -f headplane/docker-compose.yml down

# Restore configurations
echo "⚙️ Restoring configurations..."
tar -xzf "$BACKUP_PATH/configs.tar.gz" -C /opt/headscale/

# Start database
echo "📊 Starting database..."
cd /opt/headscale/database
docker-compose up -d
sleep 30

# Restore databases
echo "📊 Restoring databases..."
docker exec -i headscale_postgres psql -U headscale headscale < "$BACKUP_PATH/headscale_db.sql"
docker exec -i headscale_postgres psql -U authelia authelia < "$BACKUP_PATH/authelia_db.sql"

# Restore SSL certificates
echo "🔒 Restoring SSL certificates..."
docker run --rm -v traefik_letsencrypt:/letsencrypt -v "$BACKUP_PATH":/backup alpine:latest \
    tar -xzf /backup/letsencrypt.tar.gz -C /

# Restore Headplane data
echo "💾 Restoring Headplane data..."
docker run --rm -v headplane_headplane_data:/data -v "$BACKUP_PATH":/backup alpine:latest \
    tar -xzf /backup/headplane_data.tar.gz -C /

# Start all services
echo "🚀 Starting all services..."
cd /opt/headscale/traefik && docker-compose up -d
sleep 10
cd /opt/headscale/authelia && docker-compose up -d
sleep 10
cd /opt/headscale/headscale && docker-compose up -d
sleep 10
cd /opt/headscale/headplane && docker-compose up -d
sleep 10

echo "✅ Restore completed!"
echo "🧪 Run verification: /opt/headscale/scripts/verify-deployment.sh"