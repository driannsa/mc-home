#!/usr/bin/env bash

# Exit on errors
set -e

# Functions
info() { echo "[INFO] $*"; }
error() { echo "[ERROR] $*" >&2; exit 1; }

# Check if script is run as root (or via sudo)
if [[ $EUID -ne 0 ]]; then
  error "This script must be run as root. Use sudo."
fi

# 1. Install ZeroTier
info "Installing ZeroTier..."
curl -s https://install.zerotier.com/ | bash

# 2. Enable and start the service (systemd)
if command -v systemctl &>/dev/null; then
  info "Enabling zerotier-one service..."
  systemctl enable zerotier-one

  info "Starting zerotier-one service..."
  systemctl start zerotier-one
else
  info "systemctl not found — please start zerotier-one manually if needed"
fi

# 3. Optionally join a network
# You can pass a network ID as the first argument to the script
NETWORK_ID="$1"
if [[ -n "$NETWORK_ID" ]]; then
  info "Joining ZeroTier network: $NETWORK_ID"
  zerotier-cli join "$NETWORK_ID"

  info "Waiting a few seconds for join to process..."
  sleep 5

  info "Listing networks:"
  zerotier-cli listnetworks
fi

# 4. Check status
info "ZeroTier status:"
zerotier-cli status

info "Done."
