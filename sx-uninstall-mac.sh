#!/usr/bin/env bash
# sx-uninstall-mac.sh — Remove macOS SearxNG Local install
set -e

INSTALL_DIR="$HOME/Documents/searxng-mac"

echo "🧹 Removing SearxNG local installation..."
pkill -f "searx/webapp.py" 2>/dev/null || true
rm -rf "$INSTALL_DIR"
echo "✅ SearxNG removed from your system."
