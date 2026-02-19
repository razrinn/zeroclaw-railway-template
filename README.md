# ZeroClaw Railway Template

ZeroClaw deployed on Railway with persistent storage.

## Overview

This template deploys [ZeroClaw](https://github.com/zeroclaw-labs/zeroclaw) - a lean, fast AI agent runtime written in Rust - to Railway with a persistent volume for configuration and data.

## Features

- **Auto-starting daemon**: Container automatically runs `zeroclaw daemon` on boot
- **Persistent storage**: Configuration, workspace, and sessions survive redeploys
- **SSH access**: Railway's terminal feature lets you run commands interactively
- **Terminal-only**: No web UI - use SSH to configure and interact

## Deployment

### 1. Deploy to Railway

Click the button below to deploy:

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/rHDX80?referralCode=pNTW1S&utm_medium=integration&utm_source=template&utm_campaign=generic)

Or manually:
1. Fork this repo
2. Create new project in Railway
3. Connect your forked repo
4. Deploy

### 2. Initial Setup (via Railway Terminal)

Once deployed, open the Railway terminal and run:

```bash
# Configure ZeroClaw with your API key
zeroclaw onboard --api-key sk-your-key-here --provider openrouter

# Or run the interactive wizard
zeroclaw onboard --interactive
```

### 3. Check Status

```bash
zeroclaw status
```

The daemon is already running in the background. Once you configure it, channels and scheduled tasks will start working.

## Usage

### Common Commands

```bash
# Check system status
zeroclaw status

# Chat with the agent
zeroclaw agent -m "Hello, what can you do?"

# Interactive chat mode
zeroclaw agent

# Check channel health
zeroclaw channel doctor

# Bind Telegram user (after setting up Telegram bot)
zeroclaw channel bind-telegram 123456789

# View logs
zeroclaw logs
```

### Configuration

Configuration is stored at `/data/.zeroclaw/config.toml`. You can edit it directly:

```bash
nano /data/.zeroclaw/config.toml
```

Or use the onboard command to reconfigure:

```bash
zeroclaw onboard
```

## Data Persistence

All data is stored in `/data/` which is mounted as a persistent Railway volume:

| Path | Contents |
|------|----------|
| `/data/.zeroclaw/config.toml` | Main configuration |
| `/data/.zeroclaw/.secret_key` | Encryption key for secrets |
| `/data/workspace/` | Working directory for agent operations |
| `/data/.zeroclaw/cron/` | Scheduled task definitions |
| `/data/.zeroclaw/sessions/` | Session data |
| `/data/.zeroclaw/npm-packages.txt` | List of npm packages to auto-install |
| `/data/.zeroclaw/brew-packages.txt` | List of Homebrew packages to auto-install |
| `/data/.npm-global/` | Persisted npm global packages |
| `/data/.npm-cache/` | Persisted npm cache |
| `/data/.linuxbrew/` | Persisted Homebrew installation |

### NPM Packages Persistence

NPM packages installed globally will survive redeploys. You can manage them in two ways:

**Method 1: Auto-install from list**
Create `/data/.zeroclaw/npm-packages.txt` with packages to auto-install on startup:

```bash
# In Railway terminal
cat > /data/.zeroclaw/npm-packages.txt << 'EOF'
# Add your npm packages here, one per line
# Example packages:
typescript
@angular/cli
@nestjs/cli
EOF

# Restart container to apply
```

**Method 2: Manual install (also persists)**
```bash
npm install -g <package-name>
# or
npx install -g <package-name>
```

Packages are installed to `/data/.npm-global/` which is persisted across redeploys.

### Homebrew Packages Persistence

Homebrew (Linuxbrew) is also available with persistent storage. You can manage packages in two ways:

**Method 1: Auto-install from list**
Create `/data/.zeroclaw/brew-packages.txt` with packages to auto-install on startup:

```bash
# In Railway terminal
cat > /data/.zeroclaw/brew-packages.txt << 'EOF'
# Add your Homebrew packages here, one per line
# Example packages:
jq
htop
tree
EOF

# Restart container to apply
```

**Method 2: Manual install (also persists)**
```bash
brew install <package-name>
```

Packages are installed to `/data/.linuxbrew/` which is persisted across redeploys. Brew is automatically available in the shell via `/etc/bash.bashrc`.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HOME` | `/data` | Sets home directory (ZeroClaw uses `~/.zeroclaw` = `/data/.zeroclaw`) |
| `ZEROCLAW_WORKSPACE` | `/data/workspace` | Workspace directory |
| `ZEROCLAW_VERSION` | `main` | Git branch/tag to build from |

## Local Testing

```bash
# Build the image
docker build -t railway-zeroclaw .

# Run locally
docker run --rm -it \
  -p 3000:3000 \
  -v $(pwd)/.tmpdata:/data \
  railway-zeroclaw

# In another terminal, exec into container
docker exec -it <container-id> /bin/bash
zeroclaw status
```

## Architecture

- **Dockerfile**: Multi-stage build (Rust builder + Debian runtime)
- **start.sh**: Launches `zeroclaw daemon` on container start
- **railway.toml**: Configures Railway deployment with persistent volume

The daemon runs as PID 1 in the container, handling signals properly for graceful shutdown.

## Getting API Keys

### OpenRouter (recommended)
1. Visit [openrouter.ai](https://openrouter.ai)
2. Create account and get API key
3. Supports many models (Claude, GPT-4, etc.)

### Telegram Bot
1. Message [@BotFather](https://t.me/BotFather) on Telegram
2. Run `/newbot` and follow prompts
3. Copy the token
4. Add your user ID to allowlist

### Discord Bot
1. Go to [Discord Developer Portal](https://discord.com/developers/applications)
2. New Application → Bot → Add Bot
3. Enable MESSAGE CONTENT INTENT
4. Copy Bot Token
5. Invite bot to your server

See [ZeroClaw documentation](https://github.com/zeroclaw-labs/zeroclaw) for more channels.

## Troubleshooting

**Daemon not running?**
```bash
# Check if process is alive
ps aux | grep zeroclaw

# Check logs
zeroclaw logs
```

**Config not persisting?**
- Ensure volume is mounted at `/data`
- Check `HOME` env var is set to `/data`

**Build fails?**
- Check `ZEROCLAW_VERSION` exists on GitHub
- Rust build can take 5-10 minutes on first deploy

## License

MIT - See [ZeroClaw License](https://github.com/zeroclaw-labs/zeroclaw/blob/main/LICENSE)
