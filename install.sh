#!/usr/bin/env bash
set -euo pipefail

REPO="Eventyret/peapod-dist"
BIN="peapod"
DIR="${PEAPOD_BIN_DIR:-$HOME/.local/bin}"
BASE="${PEAPOD_DOWNLOAD_BASE:-https://github.com/$REPO/releases/latest/download}"

os="$(uname -s)"
arch="$(uname -m)"
case "$os" in
  Darwin) os="macos" ;;
  Linux) os="linux" ;;
  *) echo "Unsupported OS: $os"; exit 1 ;;
esac
case "$arch" in
  arm64 | aarch64) arch="arm64" ;;
  x86_64 | amd64) arch="x64" ;;
  *) echo "Unsupported architecture: $arch"; exit 1 ;;
esac
asset="${BIN}-${os}-${arch}"
url="$BASE/$asset.gz"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
echo "Downloading $asset ..."
if ! curl -fsSL "$url" -o "$tmp/$BIN.gz"; then
  echo "Download failed from $url"
  echo "Is there a published release yet? See https://github.com/$REPO/releases"
  exit 1
fi
gunzip "$tmp/$BIN.gz"

mkdir -p "$DIR"
chmod +x "$tmp/$BIN"
mv "$tmp/$BIN" "$DIR/$BIN"
if [ "$os" = "macos" ]; then
  xattr -dr com.apple.quarantine "$DIR/$BIN" 2>/dev/null || true
fi

echo "Installed $BIN to $DIR/$BIN"
case ":$PATH:" in
  *":$DIR:"*) ;;
  *)
    echo "$DIR is not on your PATH. Add it, then restart your shell:"
    echo "  echo 'export PATH=\"$DIR:\$PATH\"' >> ~/.zshrc"
    ;;
esac

"$DIR/$BIN" --version
if [ -d "$HOME/.claude" ]; then
  "$DIR/$BIN" skill >/dev/null 2>&1 && echo "Installed the Claude Code skill to ~/.claude/skills/peapod"
fi
echo "Next: run peapod setup"
