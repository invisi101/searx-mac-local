#!/usr/bin/env bash
# stop-searx-mac.sh — Stop SearxNG on macOS

if pgrep -f "searx/webapp.py" >/dev/null; then
  pkill -f "searx/webapp.py"
  echo "SearxNG stopped."
else
  echo "SearxNG is not running."
fi
