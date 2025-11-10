#!/usr/bin/env bash
# sx-deploy-mac.sh — macOS installer for SearxNG Local
set -euo pipefail

APP_NAME="SearxNG"
INSTALL_DIR="$HOME/Documents/searxng-mac"
REPO_DIR="$INSTALL_DIR/searxng"
VENV_DIR="$INSTALL_DIR/venv"
PY_APP="$REPO_DIR/searx/webapp.py"
CONFIG="$INSTALL_DIR/settings.yml"
USER_BIN="$HOME/.local/bin"
CLI_BIN="$USER_BIN/searxng"

echo "🧩 Installing SearxNG (macOS local version)"
echo "---------------------------------------------"

# Check and install Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "[*] Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install dependencies
echo "[*] Checking prerequisites with brew..."
brew install -q git python@3.12 || true

# Use Python 3.12 if available
if command -v python3.12 >/dev/null 2>&1; then
  PYTHON_BIN="python3.12"
else
  PYTHON_BIN="python3"
fi

echo "Using Python: $(which $PYTHON_BIN)"

# Ensure install directory exists
mkdir -p "$INSTALL_DIR"

# Clone or update SearxNG
if [ ! -d "$REPO_DIR/.git" ]; then
  echo "📥 Cloning SearxNG repository..."
  git clone https://github.com/searxng/searxng "$REPO_DIR"
else
  echo "📦 Updating existing SearxNG repository..."
  (cd "$REPO_DIR" && git pull)
fi

# Create venv
if [ ! -d "$VENV_DIR" ]; then
  echo "🐍 Creating Python virtual environment..."
  $PYTHON_BIN -m venv "$VENV_DIR"
fi
source "$VENV_DIR/bin/activate"

echo "📦 Installing dependencies..."
pip install -U pip setuptools wheel
(cd "$REPO_DIR" && pip install --use-pep517 --no-build-isolation -e .)
deactivate

echo "⚙️ Configuring SearxNG..."
cp "$REPO_DIR/searx/settings.yml" "$CONFIG"

# Generate a proper secret key
SECRET=$(openssl rand -hex 32)
sed -i '' "s/secret_key: .*/secret_key: \"$SECRET\"/" "$CONFIG"

# Add silent logging section
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

echo "🚀 Creating start/stop scripts..."
mkdir -p "$USER_BIN"

# START SCRIPT
cat >"$USER_BIN/start-searxng" <<EOF
#!/usr/bin/env bash
source "$VENV_DIR/bin/activate"
export SEARXNG_SETTINGS_PATH="$CONFIG"
nohup python3 "$PY_APP" >/dev/null 2>&1 &
disown
echo "SearxNG started at http://127.0.0.1:8888"
EOF
chmod +x "$USER_BIN/start-searxng"

# STOP SCRIPT
cat >"$USER_BIN/stop-searxng" <<'EOF'
#!/usr/bin/env bash
if pgrep -f "searx/webapp.py" >/dev/null; then
  pkill -f "searx/webapp.py"
  echo "SearxNG stopped."
else
  echo "SearxNG is not running."
fi
EOF
chmod +x "$USER_BIN/stop-searxng"

# Ensure ~/.local/bin is in PATH
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zprofile
  echo "✅ Added ~/.local/bin to PATH in ~/.zprofile"
fi

echo "✅ Installation complete."
echo "Run 'start-searxng' to launch, or 'stop-searxng' to stop."
