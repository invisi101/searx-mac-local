#!/usr/bin/env bash
# sx-deploy-mac.sh — macOS installer for SearxNG Local
set -euo pipefail

APP_NAME="SearxNG"
INSTALL_DIR="$HOME/Documents/searxng-mac"
REPO_DIR="$INSTALL_DIR/searxng"
VENV_DIR="$INSTALL_DIR/venv"
PY_APP="$REPO_DIR/searx/webapp.py"
CONFIG="$INSTALL_DIR/settings.yml"

echo "🧩 Installing $APP_NAME (macOS local version)"
echo "---------------------------------------------"

if ! command -v brew &>/dev/null; then
  echo "❌ Homebrew not found. Please install it first from https://brew.sh"
  exit 1
fi

brew install python3 git

mkdir -p "$INSTALL_DIR"

if [ ! -d "$REPO_DIR/.git" ]; then
  echo "📥 Cloning SearxNG repository..."
  git clone https://github.com/searxng/searxng "$REPO_DIR"
else
  echo "🔄 Updating existing SearxNG repository..."
  (cd "$REPO_DIR" && git pull)
fi

if [ ! -d "$VENV_DIR" ]; then
  echo "🐍 Creating Python virtual environment..."
  python3 -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"
echo "📦 Installing dependencies..."
pip install -U pip setuptools wheel pyyaml msgspec redis httpx uvloop
(cd "$REPO_DIR" && pip install --use-pep517 --no-build-isolation -e .)
deactivate

echo "⚙️  Generating settings..."
cp "$REPO_DIR/searx/settings.yml" "$CONFIG"
sed -i '' "s|ultrasecretkey|$(openssl rand -hex 32)|" "$CONFIG"

cat >>"$CONFIG" <<'YAML'
logging:
  version: 1
  disable_existing_loggers: true
  root:
    level: CRITICAL
    handlers: []
  loggers:
    searx:
      level: CRITICAL
      handlers: []
      propagate: false
YAML

cat >"$INSTALL_DIR/start-searx-mac.sh"<<EOF
#!/usr/bin/env bash
source "$VENV_DIR/bin/activate"
export SEARXNG_SETTINGS_PATH="$CONFIG"
nohup python "$PY_APP" >/dev/null 2>&1 &
disown
echo "$APP_NAME started at http://127.0.0.1:8888"
EOF
chmod +x "$INSTALL_DIR/start-searx-mac.sh"

cat >"$INSTALL_DIR/stop-searx-mac.sh"<<'EOF'
#!/usr/bin/env bash
if pgrep -f "searx/webapp.py" >/dev/null; then
  pkill -f "searx/webapp.py"
  echo "SearxNG stopped."
else
  echo "SearxNG is not running."
fi
EOF
chmod +x "$INSTALL_DIR/stop-searx-mac.sh"

echo
cat <<'INFO'
✅ Installation complete!

Access your private SearxNG instance at:
  http://127.0.0.1:8888

Control commands:
  ~/Documents/searxng-mac/start-searx-mac.sh   → Start the service
  ~/Documents/searxng-mac/stop-searx-mac.sh    → Stop the service

To remove everything:
  bash ~/Documents/searx-mac-local/sx-uninstall-mac.sh
INFO
