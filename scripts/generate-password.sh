#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <password>"
    echo "Example: $0 SecurePassword123!"
    exit 1
fi

PASSWORD="$1"

# Generate hash using authelia docker image
docker run --rm -it authelia/authelia:4.38.10 authelia crypto hash generate argon2 --password "$PASSWORD"
EOF

chmod +x /home/headscale/tail-headscale/scripts/generate-password.sh

# Generate hashes cho users (replace passwords with your own)
echo "🔐 Generating password hashes..."
ADMIN_HASH=$(/home/headscale/tail-headscale/scripts/generate-password.sh "AdminPassword123!")
MANAGER_HASH=$(/home/headscale/tail-headscale/scripts/generate-password.sh "ManagerPassword123!")
USER_HASH=$(/home/headscale/tail-headscale/scripts/generate-password.sh "UserPassword123!")

echo "Admin hash: $ADMIN_HASH"
echo "Manager hash: $MANAGER_HASH"  
echo "User hash: $USER_HASH"