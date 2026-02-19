#!/bin/bash
set -e

# Ensure directories exist
mkdir -p /data/.zeroclaw /data/workspace /data/.zeroclaw/logs /data/.npm-global /data/.npm-cache

# Configure npm to use persistent storage
npm config set prefix '/data/.npm-global'
npm config set cache '/data/.npm-cache'

# Install npm packages from persistent list (if exists)
NPM_PACKAGES_FILE="/data/.zeroclaw/npm-packages.txt"
if [ -f "$NPM_PACKAGES_FILE" ]; then
    echo "Installing npm packages from $NPM_PACKAGES_FILE..."
    while IFS= read -r package || [[ -n "$package" ]]; do
        # Skip empty lines and comments
        [[ -z "$package" || "$package" =~ ^# ]] && continue
        
        if ! npm list -g "$package" &>/dev/null; then
            echo "Installing $package..."
            npm install -g "$package"
        else
            echo "$package is already installed"
        fi
    done < "$NPM_PACKAGES_FILE"
fi

# Install Homebrew if not present (to persistent location)
if [ ! -f "/data/.linuxbrew/bin/brew" ]; then
    echo "Installing Homebrew to persistent storage..."
    export NONINTERACTIVE=1
    export HOMEBREW_PREFIX=/data/.linuxbrew
    export HOMEBREW_CELLAR=/data/.linuxbrew/Cellar
    export HOMEBREW_REPOSITORY=/data/.linuxbrew/Homebrew
    
    # Clone Homebrew repository
    git clone --depth=1 https://github.com/Homebrew/brew "$HOMEBREW_REPOSITORY"
    
    # Create necessary directories
    mkdir -p "$HOMEBREW_PREFIX/bin"
    mkdir -p "$HOMEBREW_PREFIX/etc"
    mkdir -p "$HOMEBREW_PREFIX/include"
    mkdir -p "$HOMEBREW_PREFIX/lib"
    mkdir -p "$HOMEBREW_PREFIX/opt"
    mkdir -p "$HOMEBREW_PREFIX/sbin"
    mkdir -p "$HOMEBREW_PREFIX/share"
    mkdir -p "$HOMEBREW_PREFIX/var"
    
    # Symlink brew to bin
    ln -sf "$HOMEBREW_REPOSITORY/bin/brew" "$HOMEBREW_PREFIX/bin/brew"
    
    echo "Homebrew installed successfully!"
fi

# Configure shell environment for Homebrew
echo 'eval "$(/data/.linuxbrew/bin/brew shellenv)"' >> /etc/bash.bashrc

# Install Homebrew packages from persistent list (if exists)
HOMEBREW_PACKAGES_FILE="/data/.zeroclaw/brew-packages.txt"
if [ -f "$HOMEBREW_PACKAGES_FILE" ]; then
    echo "Installing Homebrew packages from $HOMEBREW_PACKAGES_FILE..."
    eval "$(/data/.linuxbrew/bin/brew shellenv)"
    while IFS= read -r package || [[ -n "$package" ]]; do
        # Skip empty lines and comments
        [[ -z "$package" || "$package" =~ ^# ]] && continue
        
        if ! brew list "$package" &>/dev/null; then
            echo "Installing $package..."
            brew install "$package"
        else
            echo "$package is already installed"
        fi
    done < "$HOMEBREW_PACKAGES_FILE"
fi

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
