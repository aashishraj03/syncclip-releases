#!/bin/bash
# SyncClip installer for macOS
# Usage: curl -fsSL https://raw.githubusercontent.com/aashishraj03/syncclip-releases/main/install.sh | bash

set -euo pipefail

REPO="aashishraj03/syncclip-releases"
APP="SyncClip"

if [ "$(uname -s)" != "Darwin" ]; then
  echo "This installer is for macOS only."
  exit 1
fi

ARCH="$(uname -m)"   # arm64 (Apple Silicon) or x86_64 (Intel)
URL="https://github.com/${REPO}/releases/latest/download/${APP}-${ARCH}.zip"

# Install to /Applications, or ~/Applications if the user can't write there
DEST="/Applications"
if [ ! -w "$DEST" ]; then
  DEST="$HOME/Applications"
  mkdir -p "$DEST"
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Downloading ${APP} for ${ARCH}..."
if ! curl -fL --progress-bar "$URL" -o "$TMP/${APP}.zip"; then
  echo "Download failed. There may be no build for this Mac type (${ARCH}) yet."
  exit 1
fi

# Stop any running copy and replace the old version
pkill -x "$APP" 2>/dev/null || true
rm -rf "${DEST}/${APP}.app"

echo "Installing to ${DEST}..."
ditto -x -k "$TMP/${APP}.zip" "$DEST"
xattr -cr "${DEST}/${APP}.app"

echo "Done. Opening ${APP}..."
open "${DEST}/${APP}.app"
