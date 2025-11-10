#!/usr/bin/env bash
set -euo pipefail

APP_DIR=”$HOME/Documents/searxng-mac”
REPO_DIR=”$APP_DIR/searxng”
VENV_DIR=”$APP_DIR/venv”
CONFIG=”$APP_DIR/settings.yml”
USER_BIN=”$HOME/.local/bin”

echo “Installing SearxNG (macOS local)”
echo “––––––––––––––––”

brew install python@3.12 git || true

PYTHON=”/opt/homebrew/opt/python@3.12/bin/python3.12”
echo “Using Python: $PYTHON”

mkdir -p “$APP_DIR”

echo “Cloning SearxNG…”
rm -rf “$REPO_DIR”
git clone https://github.com/searxng/searxng “$REPO_DIR”

echo “Creating virtual environment…”
rm -rf “$VENV_DIR”
$PYTHON -m venv “$VENV_DIR”
source “$VENV_DIR/bin/activate”

echo “Installing dependencies…”
pip install -U pip setuptools wheel
pip install whitenoise flask-babel markdown-it-py httpx-socks valkey typer

echo “Generating config…”
SECRET=$(openssl rand -hex 32)

cat > “$CONFIG” <<EOF
use_default_settings: false

server:
port: 8888
bind_address: “127.0.0.1”
base_url: “http://127.0.0.1:8888/”
secret_key: “$SECRET”

ui:
static_use_hash: true
debug: false
EOF

mkdir -p “$USER_BIN”

cat > “$USER_BIN/start-searxng” <<EOF
#!/usr/bin/env bash
source “$VENV_DIR/bin/activate”
export PYTHONPATH=”$REPO_DIR”
export SEARXNG_SETTINGS_PATH=”$CONFIG”
nohup python “$REPO_DIR/searx/webapp.py” >/dev/null 2>&1 &
echo “Started SearxNG at http://127.0.0.1:8888”
EOF
chmod +x “$USER_BIN/start-searxng”

cat > “$USER_BIN/stop-searxng” <<EOF
#!/usr/bin/env bash
pkill -f “searx/webapp.py” && echo “SearxNG stopped.”
EOF
chmod +x “$USER_BIN/stop-searxng”

echo “Done.”
echo “Use: start-searxng   and   stop-searxng”
