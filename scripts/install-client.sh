#!/bin/bash

echo "📱 TAILSCALE CLIENT INSTALLATION"
echo "================================"

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🐧 Detected Linux - Installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Detected macOS - Please install from App Store or:"
    echo "   brew install tailscale"
    exit 1
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo "🪟 Detected Windows - Please download from:"
    echo "   https://tailscale.com/download/windows"
    exit 1
else
    echo "❓ Unknown OS. Please visit: https://tailscale.com/download"
    exit 1
fi

echo ""
echo "🔌 To connect to company VPN:"
echo "sudo tailscale up --login-server=https://tailscale.company.vn"
echo ""
echo "🔑 Or use preauth key:"
echo "sudo tailscale up --login-server=https://tailscale.company.vn --authkey=YOUR_PREAUTH_KEY"
echo ""
echo "✅ After connection, test with:"
echo "tailscale status"
echo "tailscale ping 100.64.0.1"