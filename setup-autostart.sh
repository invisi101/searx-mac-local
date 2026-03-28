#!/usr/bin/env bash
# setup-autostart.sh — Enable SearxNG auto-start on login (macOS)
set -e

INSTALL_DIR="$HOME/Documents/searxng-mac"
VENV_DIR="$INSTALL_DIR/venv"
PY_APP="$INSTALL_DIR/searxng/searx/webapp.py"
CONFIG="$INSTALL_DIR/settings.yml"
PLIST_NAME="com.searxng.local"
PLIST_FILE="$HOME/Library/LaunchAgents/$PLIST_NAME.plist"

if [ ! -d "$INSTALL_DIR" ]; then
  echo "SearxNG is not installed. Please run sx-deploy-mac.sh first."
  exit 1
fi

echo "Setting up SearxNG auto-start..."

mkdir -p "$HOME/Library/LaunchAgents"

cat > "$PLIST_FILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$PLIST_NAME</string>
    <key>ProgramArguments</key>
    <array>
        <string>$VENV_DIR/bin/python</string>
        <string>$PY_APP</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>SEARXNG_SETTINGS_PATH</key>
        <string>$CONFIG</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$INSTALL_DIR/searxng.log</string>
    <key>StandardErrorPath</key>
    <string>$INSTALL_DIR/searxng.error.log</string>
</dict>
</plist>
EOF

launchctl unload "$PLIST_FILE" 2>/dev/null || true
launchctl load "$PLIST_FILE"

echo
echo "Auto-start enabled and SearxNG is now running."
echo "It will automatically launch whenever you log in."
echo "Access it at: http://127.0.0.1:8888"
echo
echo "To disable auto-start later, run:"
echo "  launchctl unload $PLIST_FILE"
