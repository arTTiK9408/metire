#!/bin/sh
#
# Metire — install.sh
# Usage: curl -sS https://raw.githubusercontent.com/arTTiK9408/metire/main/install.sh | sh
#
# MIT License — https://github.com/arTTiK9408/metire

set -eu

REPO="arTTiK9408/metire"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
BINARY="metire"

main() {
  need_cmd curl
  need_cmd uname
  need_cmd install

  os=$(uname -s)
  arch=$(uname -m)

  case "$os" in
    Linux)  asset="metire-linux-x86_64" ;;
    Darwin) asset="metire-darwin-x86_64" ;;
    *)
      err "unsupported OS: $os"
      ;;
  esac

  case "$arch" in
    x86_64|amd64) ;;
    aarch64|arm64)
      asset="$(echo "$asset" | sed 's/x86_64/aarch64/')"
      ;;
    *)
      err "unsupported architecture: $arch"
      ;;
  esac

  info "looking up latest release..."
  tag=$(curl -sSfL "https://api.github.com/repos/$REPO/releases/latest" \
        | grep '"tag_name":' | cut -d'"' -f4)
  [ -z "$tag" ] && err "could not fetch latest release tag"

  url="https://github.com/$REPO/releases/download/$tag/$asset"
  tmp="/tmp/$BINARY.$$"

  info "downloading metire $tag..."
  curl -#fL "$url" -o "$tmp"

  [ -s "$tmp" ] || err "downloaded file is empty"

  header=$(dd if="$tmp" bs=1 count=4 2>/dev/null | od -A n -t x1 | tr -d ' ')
  case "$os" in
    Linux)
      [ "$header" = "7f454c46" ] || err "invalid ELF header"
      ;;
    Darwin)
      [ "$header" = "cffaedfe" ] || err "invalid Mach-O header"
      ;;
  esac

  info "installing to $INSTALL_DIR/$BINARY..."
  if [ -w "$INSTALL_DIR" ]; then
    install -m755 "$tmp" "$INSTALL_DIR/$BINARY"
  else
    if command -v sudo >/dev/null 2>&1; then
      sudo install -m755 "$tmp" "$INSTALL_DIR/$BINARY"
    else
      err "need write access to $INSTALL_DIR (try: sudo)"
    fi
  fi

  rm -f "$tmp"
  info "metire $tag installed to $INSTALL_DIR/$BINARY"
}

info()  { printf "\033[32mmetire\033[0m %s\n" "$*"; }
err()   { printf "\033[31mmetire\033[0m error: %s\n" "$*" >&2; exit 1; }
need_cmd() {
  command -v "$1" >/dev/null 2>&1 || err "required command '$1' not found"
}

main
