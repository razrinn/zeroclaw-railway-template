#!/bin/bash
set -e

# Ensure directories exist
mkdir -p /data/.zeroclaw /data/workspace /data/.zeroclaw/logs

# Check if config exists
CONFIG_FILE="/data/.zeroclaw/config.toml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "=========================================="
    echo "ZeroClaw is not configured yet!"
    echo ""
    echo "To get started:"
    echo "1. Open Railway terminal for this service"
    echo "2. Run: zeroclaw onboard --api-key YOUR_KEY --provider openrouter"
    echo "   Or: zeroclaw onboard --interactive"
    echo ""
    echo "3. Restart the container after configuration"
    echo "=========================================="
    echo ""
    echo "Container is running but waiting for config..."
    echo "(Keep this running so you can access the terminal)"
    
    # Keep container alive so user can SSH in
    while [ ! -f "$CONFIG_FILE" ]; do
        sleep 5
    done
    
    echo "Config detected! Starting ZeroClaw..."
fi

echo "Starting ZeroClaw daemon..."
# Note: daemon already includes channels - don't run channel start separately
exec zeroclaw daemon
