#!/usr/bin/env bash
set -euo pipefail

REPO="Eventyret/peapod-dist"
dir="$HOME/.local/bin"
tag=""

fail() {
  echo "Error: $1" >&2
  [ $# -lt 2 ] || echo "Fix: $2" >&2
  exit 1
}

usage() {
  echo "Usage: install.sh [--dir <folder>] [--version <tag>]"
  echo "  --dir <folder>    Install here. Default: ~/.local/bin"
  echo "  --version <tag>   Install this release, for example v0.5.0. Default: latest"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dir)
      [ $# -ge 2 ] || fail "--dir needs a folder." "install.sh --dir ~/bin"
      dir="$2"
      shift 2
      ;;
    --version)
      [ $# -ge 2 ] || fail "--version needs a tag." "install.sh --version v0.5.0"
      tag="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown option: $1" "install.sh --help"
      ;;
  esac
done

case "$(uname -s)" in
  Darwin) os="macos" ;;
  Linux) os="linux" ;;
  *) fail "peapod has no build for $(uname -s)." "Use macOS or Linux." ;;
esac
case "$(uname -m)" in
  arm64 | aarch64) arch="arm64" ;;
  x86_64 | amd64) arch="x64" ;;
  *) fail "peapod has no build for $(uname -m)." "Use an arm64 or x64 machine." ;;
esac

if [ -z "$tag" ]; then
  base="https://github.com/$REPO/releases/latest/download"
else
  case "$tag" in v*) ;; *) tag="v$tag" ;; esac
  base="https://github.com/$REPO/releases/download/$tag"
fi

asset="peapod-$os-$arch"

hash_of() {
  if command -v sha256sum > /dev/null 2>&1; then
    sha256sum "$1" | cut -d ' ' -f 1
  elif command -v shasum > /dev/null 2>&1; then
    shasum -a 256 "$1" | cut -d ' ' -f 1
  else
    fail "No sha256 tool found." "Install coreutils or perl, then run this again."
  fi
}

fetch() {
  curl -fsSL --connect-timeout 15 --retry 2 "$1" -o "$2" ||
    if [ -n "$tag" ]; then
      fail "Download failed: $1" "Release $tag may not exist. See https://github.com/$REPO/releases, or check your network."
    else
      fail "Download failed: $1" "Check your network. Releases: https://github.com/$REPO/releases"
    fi
}

verified_download() {
  fetch "$base/$1" "$tmp/$1"
  fetch "$base/$1.sha256" "$tmp/$1.sha256"
  expected="$(cut -d ' ' -f 1 < "$tmp/$1.sha256")"
  actual="$(hash_of "$tmp/$1")"
  [ "$expected" = "$actual" ] || fail "Checksum does not match for $1. Nothing was installed." "Run this again in a few minutes."
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Downloading $asset ${tag:-latest}"
verified_download "$asset.gz"

mkdir -p "$dir" 2> /dev/null || fail "Cannot create $dir." "Choose a folder you own: install.sh --dir ~/bin"
[ -w "$dir" ] || fail "Cannot write to $dir." "Choose a folder you own: install.sh --dir ~/bin"

staged="$dir/.peapod-install.$$"
trap 'rm -rf "$tmp" "$staged"' EXIT
gunzip -c "$tmp/$asset.gz" > "$staged" ||
  fail "The download is not a valid gzip file. Nothing was installed." "Run this again in a few minutes."
chmod +x "$staged"
if [ "$os" = "macos" ]; then
  xattr -dr com.apple.quarantine "$staged" 2> /dev/null || true
fi
"$staged" --version > /dev/null 2>&1 || fail "The downloaded peapod does not start on this machine." "Report it at https://github.com/$REPO/issues"

if [ -f "$dir/peapod" ]; then
  cp "$dir/peapod" "$dir/peapod.prev"
fi
mv -f "$staged" "$dir/peapod"

short_dir="${dir/#$HOME/~}"
echo "Installed $("$dir/peapod" --version) to $short_dir/peapod"

skill_line="$("$dir/peapod" skill 2> /dev/null || true)"
[ -z "$skill_line" ] || echo "$skill_line"

case ":$PATH:" in
  *":$dir:"*) ;;
  *)
    echo "$short_dir is not on your PATH. Add it, then restart your shell:"
    case "$(basename "${SHELL:-}")" in
      zsh) echo "  echo 'export PATH=\"$dir:\$PATH\"' >> ~/.zshrc" ;;
      bash)
        if [ "$os" = "macos" ]; then
          echo "  echo 'export PATH=\"$dir:\$PATH\"' >> ~/.bash_profile"
        else
          echo "  echo 'export PATH=\"$dir:\$PATH\"' >> ~/.bashrc"
        fi
        ;;
      fish) echo "  fish_add_path $dir" ;;
      *) echo "  export PATH=\"$dir:\$PATH\"" ;;
    esac
    ;;
esac

echo "Next: peapod"
