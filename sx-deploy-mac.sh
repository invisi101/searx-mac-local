#!/usr/bin/env bash

set -e

echo "🧩 Installing SearxNG (macOS local)"
echo "-----------------------------------"

BASE_DIR="$HOME/Documents/searxng-mac"
SEARX_SRC="$BASE_DIR/searxng"
VENV_DIR="$BASE_DIR/venv"
SETTINGS="$BASE_DIR/settings.yml"

rm -rf "$BASE_DIR"
mkdir -p "$BASE_DIR"

echo "✅ Checking dependencies"
brew install python@3.12 git || true

PYTHON="/opt/homebrew/opt/python@3.12/bin/python3.12"
echo "Using Python: $PYTHON"

echo "📥 Cloning SearxNG..."
git clone --depth 1 https://github.com/searxng/searxng.git "$SEARX_SRC"

echo "🐍 Creating virtual environment..."
$PYTHON -m venv "$VENV_DIR"

source "$VENV_DIR/bin/activate"

echo "📦 Updating pip..."
pip install -U pip wheel setuptools

echo "📦 Installing SearxNG dependencies..."
pip install \
 msgspec \
 whitenoise \
 flask-babel \
 markdown-it-py \
 httpx-socks \
 valkey \
 typer

echo "📦 Installing SearxNG (regular mode, NOT editable)..."
pip install "$SEARX_SRC"

echo "🔐 Generating secret key..."
SECRET=$(openssl rand -hex 32)

echo "✅ Writing settings.yml"
cat > "$SETTINGS" <<EOF
server:
  port: 8888
  bind_address: "127.0.0.1"
  secret_key: "$SECRET"

ui:
  static_path: "$SEARX_SRC/searx/static"
  template_path: "$SEARX_SRC/searx/templates"
EOF

echo "✅ All done!"
echo ""
echo "To start SearxNG:"
echo "  source $VENV_DIR/bin/activate"
echo "  python -m searx.webapp --settings $SETTINGS"
echo ""
