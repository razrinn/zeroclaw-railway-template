#!/bin/bash
set -e

# Ensure directories exist
mkdir -p /data/.zeroclaw /data/workspace

# Start ZeroClaw daemon
exec zeroclaw daemon
