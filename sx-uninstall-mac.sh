#!/usr/bin/env bash
# sx-uninstall-mac.sh — Remove macOS SearxNG Local installation
set -euo pipefail

INSTALL_DIR="$HOME/Documents/searxng-mac"
USER_BIN="$HOME/.local/bin"
START_CMD="$USER_BIN/start-searxng"
STOP_CMD="$USER_BIN/stop-searxng"

echo "🧹 Uninstalling SearxNG Local"
echo "-----------------------------"

# Stop running SearxNG instance if any
if pgrep -f "searx/webapp.py" >/dev/null 2>&1; then
  echo "🛑 Stopping running SearxNG instance..."
  pkill -f "searx/webapp.py"
fi

# Remove installation directory
if [ -d "$INSTALL_DIR" ]; then
  echo "📦 Removing installation directory: $INSTALL_DIR"
  rm -rf "$INSTALL_DIR"
else
  echo "ℹ️  No installation directory found at $INSTALL_DIR"
fi

# Remove start/stop scripts
if [ -f "$START_CMD" ]; then
  echo "🗑️  Removing start-searxng command"
  rm -f "$START_CMD"
fi

if [ -f "$STOP_CMD" ]; then
  echo "🗑️  Removing stop-searxng command"
  rm -f "$STOP_CMD"
fi

# Remove ~/.local/bin if empty
if [ -d "$USER_BIN" ] && [ -z "$(ls -A "$USER_BIN")" ]; then
  echo "🧼 Removing empty folder: $USER_BIN"
  rmdir "$USER_BIN"
fi

# Remove PATH modification from ~/.zprofile (added by install script)
if grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.zprofile 2>/dev/null; then
  echo "🧽 Cleaning PATH entry in ~/.zprofile"
  sed -i '' '/export PATH="\$HOME\/\.local\/bin:\$PATH"/d' ~/.zprofile
fi

echo "✅ Uninstallation complete."
