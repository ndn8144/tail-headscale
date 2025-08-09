#!/bin/bash

echo "🧪 HEADSCALE DEPLOYMENT VERIFICATION"
echo "===================================="

# Load environment
source /opt/headscale/.env

# Test 1: Container Health
echo "1️⃣ Checking container health..."
echo "Container statuses:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(traefik|postgres|authelia|headscale|headplane)"

echo -e "\nHealthy containers:"
docker ps --filter "health=healthy" --format "table {{.Names}}\t{{.Status}}"

# Test 2: Network Connectivity
echo -e "\n2️⃣ Testing network connectivity..."
echo "Internal networks:"
docker network ls | grep -E "(proxy|headscale)"

# Test 3: SSL Certificates
echo -e "\n3️⃣ Testing SSL certificates..."
domains=("tailscale.company.vn" "admin.company.vn" "auth.company.vn")
for domain in "${domains[@]}"; do
    echo -n "  $domain: "
    if curl -Is --connect-timeout 5 https://$domain | grep -q "200 OK\|301\|302"; then
        echo "✅ OK"
    else
        echo "❌ FAILED"
    fi
done

# Test 4: Service Health Endpoints
echo -e "\n4️⃣ Testing service health endpoints..."
echo -n "  Authelia API health: "
curl -sf https://auth.company.vn/api/health > /dev/null && echo "✅ OK" || echo "❌ FAILED"

echo -n "  Headscale API: "
curl -sf -H "Authorization: Bearer $HEADSCALE_ROOT_API_KEY" \
    https://tailscale.company.vn/api/v1/users > /dev/null && echo "✅ OK" || echo "❌ FAILED"

echo -n "  Headplane UI: "
curl -sf https://admin.company.vn/ > /dev/null && echo "✅ OK" || echo "❌ FAILED"

# Test 5: Database Connectivity
echo -e "\n5️⃣ Testing database connectivity..."
echo -n "  PostgreSQL connection: "
if docker exec headscale_postgres pg_isready -U headscale -d headscale > /dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FAILED"
fi

echo -n "  Headscale database: "
if docker exec headscale_postgres psql -U headscale -d headscale -c "SELECT COUNT(*) FROM users;" > /dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FAILED"
fi

echo -n "  Authelia database: "
if docker exec headscale_postgres psql -U authelia -d authelia -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FAILED"
fi

# Test 6: OIDC Configuration
echo -e "\n6️⃣ Testing OIDC configuration..."
echo -n "  OIDC discovery endpoint: "
curl -sf https://auth.company.vn/.well-known/openid_configuration > /dev/null && echo "✅ OK" || echo "❌ FAILED"

# Test 7: Log Analysis
echo -e "\n7️⃣ Checking for errors in logs..."
echo "Recent errors in container logs:"
for container in traefik headscale_postgres authelia headscale headplane; do
    if docker ps --format "{{.Names}}" | grep -q "^$container$"; then
        errors=$(docker logs $container --since 5m 2>&1 | grep -i "error\|fail\|fatal" | wc -l)
        if [ $errors -eq 0 ]; then
            echo "  $container: ✅ No errors"
        else
            echo "  $container: ⚠️ $errors errors found"
        fi
    fi
done

# Test 8: Resource Usage
echo -e "\n8️⃣ System resource usage..."
echo "Container resource usage:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Summary
echo -e "\n📊 VERIFICATION SUMMARY"
echo "======================="
echo "✅ If all tests pass, your deployment is ready!"
echo "🌐 Access URLs:"
echo "   - Headscale Server: https://tailscale.company.vn"
echo "   - Admin UI (Headplane): https://admin.company.vn"
echo "   - Authentication (Authelia): https://auth.company.vn"
echo "   - Traefik Dashboard: https://traefik.company.vn (admin/admin123)"
echo ""
echo "🔐 Test Credentials:"
echo "   - admin@company.vn / AdminPassword123!"
echo "   - testuser@company.vn / UserPassword123!"