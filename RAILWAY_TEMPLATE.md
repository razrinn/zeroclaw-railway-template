# Deploy and Host ZeroClaw (CLI-only) on Railway

ZeroClaw is a lightweight, terminal-based AI agent runtime written in Rust. Designed for efficiency, it runs autonomously with minimal resource usage, handling AI conversations, scheduled tasks, and multi-channel integrations (Telegram, Discord, etc.) through a simple command-line interface. Perfect for developers who prefer SSH access over web UIs.

## About Hosting ZeroClaw (CLI-only)

Deploying ZeroClaw on Railway involves building the Rust binary from source in a Docker container, configuring it via SSH terminal, and running it as a persistent daemon. The setup uses a multi-stage Dockerfile that compiles ZeroClaw and runs it on a minimal Debian image. A persistent volume at `/data` ensures your configuration, API keys, and chat history survive redeploys. Once deployed, you access the container through Railway's web terminal to run initial setup commands like `zeroclaw onboard`, then the daemon auto-starts on subsequent boots. The container exposes port 8080 for webhook integrations and handles all channel polling internally.

## Common Use Cases

- **Personal AI Assistant**: Deploy a private AI agent that responds to your messages 24/7 via Telegram or Discord
- **Automated Task Scheduler**: Run cron jobs, automated scripts, and scheduled workflows with AI capabilities
- **Webhook Gateway**: Host an AI backend that receives webhooks from external services and processes them intelligently

## Dependencies for ZeroClaw (CLI-only) Hosting

- **AI Provider API Key**: OpenRouter, Anthropic, OpenAI, or compatible API key for AI model access
- **Telegram Bot Token** (optional): For Telegram integration, obtained from @BotFather

### Deployment Dependencies

- [ZeroClaw GitHub Repository](https://github.com/zeroclaw-labs/zeroclaw)
- [Railway Documentation](https://docs.railway.app/)

### Implementation Details

The deployment uses a multi-stage Docker build process:

```dockerfile
# Stage 1: Build from source
FROM rust:1.92-slim AS builder
RUN git clone https://github.com/zeroclaw-labs/zeroclaw.git .
RUN cargo build --release --locked

# Stage 2: Runtime
FROM debian:trixie-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    nano \
    vim \
    git \
    build-essential \
    procps \
    file \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/target/release/zeroclaw /usr/local/bin/
ENV HOME=/data
CMD ["zeroclaw", "daemon"]
```

Key implementation notes:

- `HOME=/data` redirects ZeroClaw's config directory from `~/.zeroclaw` to `/data/.zeroclaw`
- Persistent Railway volume mounted at `/data` preserves configuration
- Shell aliases (zc, zrc, zst) added for faster CLI usage
- Container waits for config file before starting daemon on first boot

## Why Deploy ZeroClaw (CLI-only) on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying ZeroClaw (CLI-only) on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
