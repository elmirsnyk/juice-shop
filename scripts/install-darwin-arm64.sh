#!/usr/bin/env bash
# Install juice-shop on macOS Apple Silicon (darwin arm64).
# Some native deps (sqlite3, libxmljs2) may need build tools or fail; Docker is the fallback.

set -e
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Ensure python is available (sqlite3 build may call `python`)
BINDIR="$ROOT/.bin-build"
mkdir -p "$BINDIR"
PY3="$(command -v python3 || true)"
if [ -n "$PY3" ]; then
  ln -sf "$PY3" "$BINDIR/python"
  export PATH="$BINDIR:$PATH"
fi

# Use Node from .nvmrc (18 has prebuilt arm64)
if [ -s "$HOME/.nvm/nvm.sh" ]; then
  . "$HOME/.nvm/nvm.sh"
  if ! nvm use 2>/dev/null; then
    echo "Installing Node from .nvmrc..."
    nvm install
    nvm use
  fi
fi

echo "Node: $(node -v)"
echo "Cleaning and installing..."
rm -rf node_modules package-lock.json
if npm install; then
  echo "Done. Run: npm start"
else
  echo ""
  echo "Install failed (often due to native modules on Apple Silicon). Use Docker instead:"
  echo "  docker build -t juice-shop ."
  echo "  docker run -p 3000:3000 juice-shop"
  echo "Then open http://localhost:3000"
  exit 1
fi
