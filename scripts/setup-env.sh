#!/bin/bash

# Script to setup environment variables for all modules
# Usage: ./setup-env.sh

set -e

echo "🚀 Setting up environment variables for Headscale project..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if .env file exists
check_env_file() {
    local env_file=$1
    local module=$2
    
    if [ -f "$env_file" ]; then
        echo -e "${GREEN}✅ $env_file exists for $module${NC}"
    else
        echo -e "${RED}❌ $env_file missing for $module${NC}"
    fi
}

# Check .env files for each module
echo -e "\n📁 Checking module environment files..."

# Headscale
check_env_file "headscale/.env" "Headscale"

# Authelia
check_env_file "authelia/.env" "Authelia"

# Headplane
check_env_file "headplane/.env" "Headplane"

# Database
check_env_file "database/.env" "Database"

# Traefik
check_env_file "traefik/.env" "Traefik"

# Monitoring
check_env_file "monitoring/.env" "Monitoring"

echo -e "\n🔐 Environment files check completed!"
echo -e "\n⚠️  IMPORTANT: Please verify the following values in your .env files:"
echo -e "   - Database passwords"
echo -e "   - OIDC secrets"
echo -e "   - SMTP credentials"
echo -e "   - SSL email address"
echo -e "   - HEADSCALE_ROOT_API_KEY (currently empty)"
echo -e "\n📖 See README_ENV.md for detailed instructions"
echo -e "\n🚀 You can now start your services with:"
echo -e "   docker-compose up -d"
