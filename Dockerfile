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

# Install runtime dependencies + text editors
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    nano \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Copy ZeroClaw binary from builder
COPY --from=builder /src/target/release/zeroclaw /usr/local/bin/zeroclaw

# Create data directory for persistent storage
RUN mkdir -p /data/.zeroclaw /data/workspace

# Add shell aliases for faster typing
RUN echo '# ZeroClaw aliases' >> /etc/bash.bashrc && \
    echo 'alias zc="zeroclaw"' >> /etc/bash.bashrc && \
    echo 'alias zrc="nano /data/.zeroclaw/config.toml"' >> /etc/bash.bashrc && \
    echo 'alias zst="zeroclaw status"' >> /etc/bash.bashrc && \
    echo 'alias zag="zeroclaw agent"' >> /etc/bash.bashrc && \
    echo 'alias zch="zeroclaw channel"' >> /etc/bash.bashrc

# Copy startup script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Set environment - HOME=/data makes ZeroClaw use /data/.zeroclaw
ENV HOME=/data
ENV ZEROCLAW_WORKSPACE=/data/workspace

# Expose gateway port
EXPOSE 3000

WORKDIR /data

CMD ["/app/start.sh"]
