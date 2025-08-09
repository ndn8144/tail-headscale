#!/bin/bash

echo "🔒 PRODUCTION SECURITY HARDENING"
echo "================================"

# 1. Setup fail2ban
echo "⛔ Installing fail2ban..."
sudo apt install -y fail2ban

cat > /tmp/jail.local << JAIL
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3

[traefik-auth]
enabled = true
port = http,https
filter = traefik-auth
logpath = /var/log/traefik.log
maxretry = 5
JAIL

sudo mv /tmp/jail.local /etc/fail2ban/jail.local

# Create traefik filter
cat > /tmp/traefik-auth.conf << FILTER
[Definition]
failregex = ^.*"RemoteAddr":"<HOST>".*"message":"authentication failed".*$
            ^.*"RemoteAddr":"<HOST>".*"level":"error".*$
ignoreregex =
FILTER

sudo mv /tmp/traefik-auth.conf /etc/fail2ban/filter.d/traefik-auth.conf
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# 2. Secure SSH
echo "🔐 Hardening SSH..."
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# 3. Setup automatic security updates
echo "🔄 Setting up automatic security updates..."
sudo apt install -y unattended-upgrades
echo 'Unattended-Upgrade::Automatic-Reboot "false";' | sudo tee -a /etc/apt/apt.conf.d/50unattended-upgrades

# 4. Secure file permissions
echo "📁 Securing file permissions..."
chmod 600 /opt/headscale/.env
find /opt/headscale -name "*.yml" -exec chmod 644 {} \;
find /opt/headscale -name "*.yaml" -exec chmod 644 {} \;
chmod 700 /opt/headscale/scripts/

# 5. Docker security
echo "🐳 Hardening Docker..."
# Add Docker daemon configuration
cat > /tmp/daemon.json << DOCKER
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "live-restore": true,
  "userland-proxy": false,
  "no-new-privileges": true
}
DOCKER

sudo mv /tmp/daemon.json /etc/docker/daemon.json
sudo systemctl restart docker

echo "✅ Security hardening completed!"
echo "📋 Security checklist:"
echo "   ✅ Fail2ban installed and configured"
echo "   ✅ SSH hardened (no root, key-only)"
echo "   ✅ Automatic security updates enabled"
echo "   ✅ File permissions secured"
echo "   ✅ Docker security configured"