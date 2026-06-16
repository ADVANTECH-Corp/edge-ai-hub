#!/bin/bash

# ============================================================
# Script Setup
# ============================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# ============================================================
# Browser Launch Configuration
# ============================================================
# Select browser based on OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  if command -v chromium-browser &>/dev/null; then
    chromium-browser "$URL"
  elif command -v google-chrome &>/dev/null; then
    google-chrome "$URL"
  elif command -v firefox &>/dev/null; then
    firefox "$URL"
  else
    log_error "No supported browser found. Please open the URL manually: $URL"
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  open "$URL"
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]]; then
  cmd.exe /c start "$URL"
else
  log_error "Unsupported OS. Please open the URL manually: $URL"
fi
