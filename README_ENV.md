# Environment Variables Configuration Guide

## Tổng quan
Project này đã được tách thành các module riêng biệt, mỗi module có file `.env` riêng để dễ quản lý và bảo mật.

## Cấu trúc file Environment

### 1. `headscale/.env` - Module Headscale
Các biến môi trường cho Headscale server:
- Database connection
- Server configuration
- OIDC secrets
- VPN & Network settings

### 2. `authelia/.env` - Module Authelia
Các biến môi trường cho Authelia authentication:
- Database credentials
- Security secrets (JWT, Session, Storage encryption)
- OIDC configuration
- SMTP settings

### 3. `headplane/.env` - Module Headplane
Các biến môi trường cho Headplane UI:
- OIDC configuration
- Headscale API key
- Debug settings

### 4. `database/.env` - Module Database
Các biến môi trường cho PostgreSQL database:
- Database credentials
- User permissions
- Data paths
- Backup configuration

### 5. `traefik/.env` - Module Traefik
Các biến môi trường cho Traefik reverse proxy:
- SSL configuration
- Logging settings
- Security headers
- TLS configuration

### 6. `monitoring/.env` - Module Monitoring
Các biến môi trường cho hệ thống monitoring:
- Grafana configuration
- Health check settings
- Logging configuration
- Rate limiting

## Cách sử dụng

### 1. Kiểm tra file .env
```bash
# Chạy script kiểm tra
./scripts/setup-env.sh
```

### 2. Cập nhật giá trị cần thiết
Thay thế các giá trị placeholder trong mỗi file:
- `HEADSCALE_ROOT_API_KEY` → API key thực tế từ Headscale
- Kiểm tra các passwords và secrets khác

### 3. Sử dụng trong Docker Compose
Các file docker-compose.yml đã được cấu hình để sử dụng biến môi trường từ file .env tương ứng.

## Bảo mật

### 1. Không commit file .env
Thêm vào `.gitignore`:
```
*.env
.env*
```

### 2. Sử dụng secrets management
Với production, nên sử dụng:
- Docker secrets
- Kubernetes secrets
- HashiCorp Vault
- AWS Secrets Manager

### 3. Rotate secrets định kỳ
- JWT secrets
- Database passwords
- OIDC secrets

## Troubleshooting

### 1. Kiểm tra biến môi trường
```bash
# Kiểm tra biến trong container
docker exec -it container_name env | grep VARIABLE_NAME
```

### 2. Logs
```bash
# Xem logs của service
docker-compose logs service_name
```

### 3. Restart services
```bash
# Restart sau khi thay đổi .env
docker-compose restart service_name
```

## Liên kết
- [Headscale Documentation](https://github.com/juanfont/headscale)
- [Authelia Documentation](https://www.authelia.com/)
- [Headplane Documentation](https://github.com/tale/headplane)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
