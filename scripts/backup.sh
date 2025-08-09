#!/bin/bash

# Headscale Backup Script
BACKUP_DIR="/backup/headscale"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/$DATE"

echo "🔄 Starting Headscale backup - $DATE"

# Create backup directory
mkdir -p "$BACKUP_PATH"

# Load environment
source /opt/headscale/.env

# 1. Database Backup
echo "📊 Backing up databases..."
docker exec headscale_postgres pg_dump -U headscale headscale > "$BACKUP_PATH/headscale_db.sql"
docker exec headscale_postgres pg_dump -U authelia authelia > "$BACKUP_PATH/authelia_db.sql"

# 2. Configuration Backup
echo "⚙️ Backing up configurations..."
tar -czf "$BACKUP_PATH/configs.tar.gz" -C /opt/headscale \
    traefik/config \
    headscale/config \
    headplane/config \
    authelia/config \
    .env

# 3. SSL Certificates Backup
echo "🔒 Backing up SSL certificates..."
docker run --rm -v traefik_letsencrypt:/letsencrypt -v "$BACKUP_PATH":/backup alpine:latest \
    tar -czf /backup/letsencrypt.tar.gz -C / letsencrypt

# 4. Headplane Data Backup
echo "💾 Backing up Headplane data..."
docker run --rm -v headplane_headplane_data:/data -v "$BACKUP_PATH":/backup alpine:latest \
    tar -czf /backup/headplane_data.tar.gz -C / data

# 5. Create backup manifest
echo "📋 Creating backup manifest..."
cat > "$BACKUP_PATH/manifest.txt" << MANIFEST
Headscale Backup - $DATE
=======================
Backup Location: $BACKUP_PATH
Backup Components:
- headscale_db.sql (Headscale database)
- authelia_db.sql (Authelia database)  
- configs.tar.gz (All configuration files)
- letsencrypt.tar.gz (SSL certificates)
- headplane_data.tar.gz (Headplane user data)

Container Versions:
$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -E "(headscale|authelia|traefik|postgres|headplane)")

Environment Variables:
- DB_PASSWORD: [REDACTED]
- API Keys: [REDACTED]
- OIDC Secrets: [REDACTED]

Restore Instructions:
1. Stop all containers
2. Restore database: psql -U headscale headscale < headscale_db.sql
3. Extract configs: tar -xzf configs.tar.gz -C /opt/headscale/
4. Restart services
MANIFEST

# 6. Calculate backup size
BACKUP_SIZE=$(du -sh "$BACKUP_PATH" | cut -f1)
echo "💽 Backup completed: $BACKUP_SIZE"

# 7. Cleanup old backups (keep 30 days)
find "$BACKUP_DIR" -type d -mtime +30 -exec rm -rf {} \; 2>/dev/null || true

# 8. Optional: Upload to cloud storage
# Example for AWS S3:
# aws s3 sync "$BACKUP_PATH" "s3://company-headscale-backup/$DATE/"

# Example for Google Drive (using rclone):
# rclone sync "$BACKUP_PATH" "gdrive:headscale-backup/$DATE"

echo "✅ Backup completed successfully: $BACKUP_PATH"
echo "📊 Backup size: $BACKUP_SIZE"

# Send notification (optional)
# curl -X POST -H 'Content-type: application/json' \
#   --data '{"text":"Headscale backup completed: '"$BACKUP_SIZE"'"}' \
#   YOUR_SLACK_WEBHOOK_URL