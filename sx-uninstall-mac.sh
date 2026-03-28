#!/usr/bin/env bash
# sx-uninstall-mac.sh — Remove SearxNG Local from macOS

set -e

INSTALL_DIR="$HOME/Documents/searxng-mac"
PLIST_FILE="$HOME/Library/LaunchAgents/com.searxng.local.plist"

echo "Uninstalling SearxNG..."

# Unload and remove LaunchAgent
if [ -f "$PLIST_FILE" ]; then
  echo "Removing auto-start..."
  launchctl unload "$PLIST_FILE" 2>/dev/null || true
  rm -f "$PLIST_FILE"
fi

# Stop running instance
if pgrep -f "searx/webapp.py" >/dev/null; then
  echo "Stopping running instance..."
  pkill -f "searx/webapp.py" || true
  sleep 1
fi

# Remove installation directory
if [ -d "$INSTALL_DIR" ]; then
  echo "Removing $INSTALL_DIR..."
  rm -rf "$INSTALL_DIR"
fi

echo "SearxNG has been removed."
