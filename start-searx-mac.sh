#!/usr/bin/env bash
# start-searx-mac.sh — Start SearxNG manually on macOS

SEARX_DIR="$HOME/Documents/searxng-mac"
VENV_DIR="$SEARX_DIR/venv"
PY_APP="$SEARX_DIR/searx/searx/webapp.py"
CONFIG="$SEARX_DIR/settings.yml"

if [ ! -d "$VENV_DIR" ]; then
  echo "❌ Virtual environment not found. Please run sx-deploy-mac.sh first."
  exit 1
fi

source "$VENV_DIR/bin/activate"
export SEARXNG_SETTINGS_PATH="$CONFIG"

nohup python3 "$PY_APP" >/dev/null 2>&1 &
disown
sleep 2

echo "✅ SearxNG started at http://127.0.0.1:8888"
open -a "Firefox" http://127.0.0.1:8888
