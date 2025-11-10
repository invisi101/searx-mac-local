#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="$HOME/Documents/searxng-mac"
REPO_DIR="$INSTALL_DIR/searxng"
VENV_DIR="$INSTALL_DIR/venv"
CONFIG="$INSTALL_DIR/settings.yml"
USER_BIN="$HOME/.local/bin"

echo "🧩 Installing SearxNG (macOS local)"
echo "-----------------------------------"

mkdir -p "$INSTALL_DIR"

# Install brew deps
if ! command -v brew >/dev/null; then
  echo "Homebrew missing. Install it first."
  exit 1
fi

echo "✅ Checking dependencies"
brew install python@3.12 git

PYTHON_BIN=$(brew --prefix python@3.12)/bin/python3.12

echo "Using Python: $PYTHON_BIN"

# Clone SearxNG
if [ -d "$REPO_DIR" ]; then
  rm -rf "$REPO_DIR"
fi

echo "📥 Cloning SearxNG..."
git clone https://github.com/searxng/searxng "$REPO_DIR"

# Create venv
echo "🐍 Creating virtual env..."
$PYTHON_BIN -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

echo "📦 Installing dependencies..."
pip install --upgrade pip setuptools wheel

# Hard requirements
pip install \
  whitenoise \
  flask-babel \
  markdown-it-py \
  httpx-socks \
  valkey \
  typer

# Install SearxNG package itself
echo "📦 Installing SearxNG package..."
pip install -e "$REPO_DIR"

# Generate settings.yml
echo "⚙️ Writing settings.yml..."
SECRET=$(openssl rand -hex 32)

cat > "$CONFIG" <<EOF
server:
  secret_key: "$SECRET"
  bind_address: "127.0.0.1"
  port: 8888

ui:
  static_use_hash: true

search:
  safe_search: 0
  autocomplete: "duckduckgo"

logging:
  version: 1
  disable_existing_loggers: true
  root:
    level: ERROR
    handlers: []
EOF

# Create start/stop scripts
mkdir -p "$USER_BIN"

cat > "$USER_BIN/start-searxng" <<EOF
#!/usr/bin/env bash
source "$VENV_DIR/bin/activate"
export SEARXNG_SETTINGS_PATH="$CONFIG"
nohup python -m searx.webapp >/dev/null 2>&1 &
echo "SearxNG started on http://127.0.0.1:8888"
EOF

chmod +x "$USER_BIN/start-searxng"

cat > "$USER_BIN/stop-searxng" <<EOF
#!/usr/bin/env bash
pkill -f "searx.webapp" && echo "Stopped." || echo "Already stopped."
EOF

chmod +x "$USER_BIN/stop-searxng"

echo "✅ Install complete."
echo "Run: start-searxng"
