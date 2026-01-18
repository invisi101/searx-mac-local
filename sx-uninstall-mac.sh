#!/usr/bin/env bash
# sx-uninstall-mac.sh — Remove SearxNG Local from macOS

set -e

INSTALL_DIR="$HOME/Documents/searxng-mac"

echo "Uninstalling SearxNG..."

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
