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
if ! curl -fL --progress-bar "$url" -o "$tmp/$BIN.gz"; then
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

short_dir="${DIR/#$HOME/~}"
echo "peapod $("$DIR/$BIN" --version | awk '{print $2}')"
echo "✔ Installed $short_dir/$BIN"
if [ -d "$HOME/.claude" ]; then
  PEAPOD_NO_UPDATE=1 "$DIR/$BIN" skill 2>&1 || true
fi
case ":$PATH:" in
  *":$DIR:"*) ;;
  *)
    echo "$short_dir is not on your PATH. Add it, then restart your shell:"
    echo "  echo 'export PATH=\"$DIR:\$PATH\"' >> ~/.zshrc"
    ;;
esac
echo "Next: peapod setup"
