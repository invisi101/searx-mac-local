#!/usr/bin/env bash

set -e

echo "🧩 Installing SearxNG (macOS local)"
echo "-----------------------------------"

# Base paths
BASE_DIR="$HOME/Documents/searxng-mac"
SEARX_DIR="$BASE_DIR/searxng"
VENV_DIR="$BASE_DIR/venv"

# Make sure directories are fresh
rm -rf "$BASE_DIR"
mkdir -p "$BASE_DIR"

echo "✅ Checking dependencies"
brew install python@3.12 git || true

PYTHON="/opt/homebrew/opt/python@3.12/bin/python3.12"
echo "Using Python: $PYTHON"

echo "📥 Cloning SearxNG..."
git clone --depth 1 https://github.com/searxng/searxng.git "$SEARX_DIR"

echo "🐍 Creating virtual env..."
$PYTHON -m venv "$VENV_DIR"

echo "📦 Installing required Python packages..."
source "$VENV_DIR/bin/activate"

pip install -U pip setuptools wheel

# Install all SearxNG dependencies BEFORE installing SearxNG itself
pip install \
 msgspec \
 whitenoise \
 flask-babel \
 markdown-it-py \
 httpx-socks \
 valkey \
 typer

echo "✅ Installing SearxNG (editable mode)..."
pip install -e "$SEARX_DIR"

echo "🔐 Generating secret key..."
SECRET=$(openssl rand -hex 32)

SETTINGS="$BASE_DIR/settings.yml"

echo "✅ Creating settings.yml"

cat > "$SETTINGS" <<EOF
server:
  port: 8888
  bind_address: "127.0.0.1"
  secret_key: "$SECRET"

ui:
  static_path: "$SEARX_DIR/searx/static"
  template_path: "$SEARX_DIR/searx/templates"
EOF

echo "✅ Installation complete!"
echo "To start SearxNG:"
echo ""
echo "  source $VENV_DIR/bin/activate"
echo "  python -m searx.webapp --settings $SETTINGS"
echo ""
