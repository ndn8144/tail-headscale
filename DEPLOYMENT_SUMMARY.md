# Headscale Deployment Summary

## 🚀 Deployment Information
- **Date:** $(date)
- **Version:** Headscale 0.26.0 + Headplane 0.6.0
- **Mode:** Production with OIDC authentication

## 🌐 Access URLs
- **Headscale Server:** https://tailscale.company.vn
- **Admin UI (Headplane):** https://admin.company.vn
- **Authentication (Authelia):** https://auth.company.vn
- **Monitoring (Grafana):** https://monitor.company.vn
- **Traefik Dashboard:** https://traefik.company.vn

## 🔐 Default Credentials
### Authelia Users
- **Admin:** admin@company.vn / AdminPassword123!
- **Test User:** testuser@company.vn / UserPassword123!

### Dashboard Access
- **Grafana:** admin / admin123
- **Traefik:** admin / admin123

## 📁 Important Files
- **Environment:** `/opt/headscale/.env`
- **Backup Script:** `/opt/headscale/scripts/backup.sh`
- **Restore Script:** `/opt/headscale/scripts/restore.sh`
- **Verification:** `/opt/headscale/scripts/verify-deployment.sh`

## 🔧 Management Commands

### Container Management
```bash
# Check all services status
cd /opt/headscale && find . -name "docker-compose.yml" -exec docker-compose -f {} ps \;

# Restart specific service
cd /opt/headscale/headscale && docker-compose restart

# View logs
docker logs headscale
docker logs headplane