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
    
    echo "Config detected! Starting ZeroClaw services..."
fi

# Function to cleanup processes on exit
cleanup() {
    echo "Shutting down ZeroClaw services..."
    kill $DAEMON_PID $CHANNELS_PID 2>/dev/null || true
    wait
    exit 0
}

# Trap signals for graceful shutdown
trap cleanup SIGTERM SIGINT

echo "Starting ZeroClaw daemon..."
zeroclaw daemon &
DAEMON_PID=$!

# Wait a bit for daemon to initialize
echo "Waiting for daemon to initialize..."
sleep 3

echo "Starting ZeroClaw channels..."
zeroclaw channel start &
CHANNELS_PID=$!

echo "ZeroClaw is running (daemon PID: $DAEMON_PID, channels PID: $CHANNELS_PID)"

# Wait for both processes
wait $DAEMON_PID $CHANNELS_PID
