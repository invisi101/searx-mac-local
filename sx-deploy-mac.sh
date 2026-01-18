#!/usr/bin/env bash
# sx-deploy-mac.sh — macOS installer for SearxNG Local
set -euo pipefail

APP_NAME="SearxNG"
INSTALL_DIR="$HOME/Documents/searxng-mac"
REPO_DIR="$INSTALL_DIR/searxng"
VENV_DIR="$INSTALL_DIR/venv"
CONFIG="$INSTALL_DIR/settings.yml"

echo "$APP_NAME Local Installer (macOS)"
echo "-----------------------------------"

# Check and install Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "[*] Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "[*] Installing prerequisites..."
brew install -q git python@3.11 libxml2 libxslt openssl@3 libffi pybind11 || true

PYTHON_BIN="$(brew --prefix python@3.11)/bin/python3.11"

# Set build flags so pip can find Homebrew libraries when compiling packages like lxml
export LDFLAGS="-L$(brew --prefix libxml2)/lib -L$(brew --prefix libxslt)/lib -L$(brew --prefix openssl@3)/lib -L$(brew --prefix libffi)/lib"
export CPPFLAGS="-I$(brew --prefix libxml2)/include -I$(brew --prefix libxslt)/include -I$(brew --prefix openssl@3)/include -I$(brew --prefix libffi)/include"

echo "[*] Using Python: $PYTHON_BIN"

mkdir -p "$INSTALL_DIR"

# Clone or update SearxNG
if [ ! -d "$REPO_DIR/.git" ]; then
  echo "[*] Cloning SearxNG repository..."
  git clone --depth 1 https://github.com/searxng/searxng.git "$REPO_DIR"
else
  echo "[*] Updating existing SearxNG repository..."
  (cd "$REPO_DIR" && git pull)
fi

# Create venv
echo "[*] Creating Python virtual environment..."
"$PYTHON_BIN" -m venv "$VENV_DIR"

echo "[*] Installing Python dependencies..."
"$VENV_DIR/bin/pip" install --upgrade pip setuptools wheel pybind11
"$VENV_DIR/bin/pip" install lxml babel flask-babel pyyaml msgspec httpx uvloop
"$VENV_DIR/bin/pip" install --use-pep517 --no-build-isolation -e "$REPO_DIR"

# Configure settings
echo "[*] Configuring SearxNG..."
cp "$REPO_DIR/utils/templates/etc/searxng/settings.yml" "$CONFIG"
sed -i '' "s|secret_key:.*|secret_key: \"$(openssl rand -hex 16)\"|" "$CONFIG"

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

# Copy start/stop scripts to install directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/start-searx-mac.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/stop-searx-mac.sh" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/start-searx-mac.sh" "$INSTALL_DIR/stop-searx-mac.sh"

echo
echo "-----------------------------------"
echo "$APP_NAME installed successfully."
echo
echo "Location: $INSTALL_DIR"
echo "Access:   http://127.0.0.1:8888"
echo
echo "To start: $INSTALL_DIR/start-searx-mac.sh"
echo "To stop:  $INSTALL_DIR/stop-searx-mac.sh"
echo "-----------------------------------"
