#!/usr/bin/env bash
# sx-deploy-mac.sh — macOS installer for SearxNG Local (stable, no-package-build)
set -euo pipefail

APP_NAME="SearxNG"
INSTALL_DIR="$HOME/Documents/searxng-mac"
REPO_DIR="$INSTALL_DIR/searxng"
VENV_DIR="$INSTALL_DIR/venv"
PY_APP="$REPO_DIR/searx/webapp.py"
CONFIG="$INSTALL_DIR/settings.yml"
USER_BIN="$HOME/.local/bin"

echo "🧩 Installing SearxNG (macOS local version)"
echo "---------------------------------------------"

# 0) Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "[*] Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 1) Prereqs
echo "[*] Checking prerequisites with brew..."
brew install -q git python@3.12 || true

# 2) Python pick
if command -v python3.12 >/dev/null 2>&1; then
  PYTHON_BIN="python3.12"
else
  PYTHON_BIN="python3"
fi
echo "Using Python: $(which "$PYTHON_BIN")"

# 3) Layout
mkdir -p "$INSTALL_DIR"

# 4) Clone or update SearxNG
if [ ! -d "$REPO_DIR/.git" ]; then
  echo "📥 Cloning SearxNG repository..."
  git clone https://github.com/searxng/searxng "$REPO_DIR"
else
  echo "📦 Updating SearxNG repository..."
  (cd "$REPO_DIR" && git pull --ff-only)
fi

# 5) venv
if [ ! -d "$VENV_DIR" ]; then
  echo "🐍 Creating Python virtual environment..."
  "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"

# 6) Python deps — HARD-CODED LIST (no builds triggered)
echo "📦 Installing Python dependencies..."
pip install -U pip setuptools wheel

pip install \
  flask \
  jinja2 \
  babel \
  python-dateutil \
  pyyaml \
  httpx \
  certifi \
  idna \
  chardet \
  sniffio \
  beautifulsoup4 \
  lxml \
  markdown \
  python-dotenv \
  pygments \
  langdetect \
  python-multipart \
  msgspec \
  uvloop \
  h2 \
  hpack \
  hyperframe \
  brotli \
  redis

deactivate

# 7) Configure settings.yml
echo "⚙️ Configuring SearxNG..."
cp "$REPO_DIR/searx/settings.yml" "$CONFIG" 2>/dev/null || {
  echo "❌ ERROR: Could not find settings.yml in SearxNG repo."
  exit 1
}

SECRET="$(openssl rand -hex 32)"
sed -i '' "s/secret_key: .*/secret_key: \"$SECRET\"/" "$CONFIG"

# Quiet logging
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

# 8) Start/Stop scripts
echo "🚀 Creating start/stop scripts..."
mkdir -p "$USER_BIN"

cat >"$USER_BIN/start-searxng" <<EOF
#!/usr/bin/env bash
source "$VENV_DIR/bin/activate"
export SEARXNG_SETTINGS_PATH="$CONFIG"
nohup python3 "$PY_APP" >/dev/null 2>&1 &
disown
echo "✅ SearxNG running at http://127.0.0.1:8888"
EOF
chmod +x "$USER_BIN/start-searxng"

cat >"$USER_BIN/stop-searxng" <<'EOF'
#!/usr/bin/env bash
if pgrep -f "searx/webapp.py" >/dev/null; then
  pkill -f "searx/webapp.py"
  echo "✅ SearxNG stopped."
else
  echo "⚠️ SearxNG is not running."
fi
EOF
chmod +x "$USER_BIN/stop-searxng"

# 9) PATH fix
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zprofile
  echo "✅ Added ~/.local/bin to PATH (you may need to restart terminal)"
fi

echo "✅ Installation complete!"
echo "➡️ Run: start-searxng"
echo "➡️ Stop: stop-searxng"
