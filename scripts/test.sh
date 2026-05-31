#!/usr/bin/env bash
# Quick test script to launch Quickshell with this configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_DIR="$REPO_DIR/qml"

echo "Starting Quickshell with bar configuration..."
echo "Configuration directory: $CONFIG_DIR"

# Check if quickshell is available
if ! command -v quickshell &> /dev/null; then
    echo "Error: quickshell not found in PATH"
    echo "Install with: nix-shell -p quickshell"
    exit 1
fi

# Kill existing quickshell instances
pkill quickshell || true

# Wait a moment
sleep 0.5

# Start quickshell using --path flag
echo "Launching quickshell..."
quickshell --path "$CONFIG_DIR"
