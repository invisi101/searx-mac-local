#!/usr/bin/env bash
# sx-deploy-mac.sh — macOS SearxNG local installer (stable uv version)
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

# Install Homebrew if needed
if ! command -v brew >/dev/null 2>&1; then
  echo "[*] Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "[*] Checking dependencies..."
brew install -q git python@3.12 uv || true

# Choose Python
if command -v python3.12 >/dev/null 2>&1; then
  PYTHON_BIN="python3.12"
else
  PYTHON_BIN="python3"
fi
echo "Using Python: $(which $PYTHON_BIN)"

mkdir -p "$INSTALL_DIR"

# Clone SearxNG repo
if [ ! -d "$REPO_DIR/.git" ]; then
  echo "📥 Cloning SearxNG repository..."
  git clone https://github.com/searxng/searxng "$REPO_DIR"
else
  echo "📦 Updating existing SearxNG repository..."
  (cd "$REPO_DIR" && git pull)
fi

# Create venv using uv (fast, safe, future-proof)
echo "🐍 Creating virtual environment using uv..."
uv venv "$VENV_DIR"

source "$VENV_DIR/bin/activate"

echo "📦 Installing SearxNG dependencies via uv..."
cd "$REPO_DIR"
uv pip install .

deactivate

echo "⚙️ Configuring SearxNG..."
cp "$REPO_DIR/searx/settings.yml" "$CONFIG"

# Insert random secret key
SECRET=$(openssl rand -hex 32)
sed -i '' "s/secret_key: .*/secret_key: \"$SECRET\"/" "$CONFIG"

cat >> "$CONFIG" <<'YAML'
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

# Create start/stop scripts
echo "🚀 Creating start/stop scripts..."
mkdir -p "$USER_BIN"

# START script
cat >"$USER_BIN/start-searxng" <<EOF
#!/usr/bin/env bash
source "$VENV_DIR/bin/activate"
export SEARXNG_SETTINGS_PATH="$CONFIG"
nohup python3 "$PY_APP" >/dev/null 2>&1 &
disown
echo "✅ SearxNG running at http://127.0.0.1:8888"
EOF
chmod +x "$USER_BIN/start-searxng"

# STOP script
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

# PATH fix
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zprofile
  echo "✅ Added ~/.local/bin to PATH (restart terminal)"
fi

echo "✅ Installation complete!"
echo "Run: start-searxng"
echo "Stop: stop-searxng"
