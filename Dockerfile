# syntax=docker/dockerfile:1.7

# ── Stage 1: Build ZeroClaw from source ─────────────────────────
FROM rust:1.92-slim AS builder

WORKDIR /src

# Install build dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone ZeroClaw repository
ARG ZEROCLAW_VERSION=main
RUN git clone --depth 1 --branch ${ZEROCLAW_VERSION} https://github.com/zeroclaw-labs/zeroclaw.git .

# Build ZeroClaw in release mode
RUN cargo build --release --locked

# Strip binary for smaller size
RUN strip target/release/zeroclaw

# ── Stage 2: Runtime ────────────────────────────────────────────
FROM debian:trixie-slim

# Install additional tools (nano, vim, nodejs, npm, etc.)
RUN apt-get update && apt-get install -y \
    nano \
    vim \
    git \
    build-essential \
    procps \
    file \
    curl \
    ca-certificates \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Configure npm to use persistent storage (survives redeploys)
ENV NPM_CONFIG_PREFIX=/data/.npm-global
ENV PATH="/data/.npm-global/bin:$PATH"

# Configure Homebrew to use persistent storage
ENV HOMEBREW_PREFIX=/data/.linuxbrew
ENV HOMEBREW_CELLAR=/data/.linuxbrew/Cellar
ENV HOMEBREW_REPOSITORY=/data/.linuxbrew/Homebrew
ENV PATH="/data/.linuxbrew/bin:/data/.linuxbrew/sbin:$PATH"

# Copy ZeroClaw binary from builder
COPY --from=builder /src/target/release/zeroclaw /usr/local/bin/zeroclaw

# Create data directory for persistent storage
RUN mkdir -p /data/.zeroclaw /data/.npm-global /data/.npm-cache /data/.linuxbrew

# Add shell aliases for faster typing
RUN echo '# ZeroClaw aliases' >> /etc/bash.bashrc && \
    echo 'alias zc="zeroclaw"' >> /etc/bash.bashrc && \
    echo 'alias zrc="nano /data/.zeroclaw/config.toml"' >> /etc/bash.bashrc && \
    echo 'alias zst="zeroclaw status"' >> /etc/bash.bashrc && \
    echo 'alias zag="zeroclaw agent"' >> /etc/bash.bashrc && \
    echo 'alias zch="zeroclaw channel"' >> /etc/bash.bashrc && \
    echo 'alias npm-global="npm install -g"' >> /etc/bash.bashrc && \
    echo 'alias npx-install="npx install -g"' >> /etc/bash.bashrc && \
    echo 'alias brew-install="brew install"' >> /etc/bash.bashrc && \
    echo 'eval "$(/data/.linuxbrew/bin/brew shellenv)"' >> /etc/bash.bashrc

# Copy startup script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Set environment - HOME=/data makes ZeroClaw use /data/.zeroclaw
ENV HOME=/data
ENV SHELL=/bin/bash

# Expose gateway port
EXPOSE 8080

WORKDIR /data

CMD ["/app/start.sh"]
