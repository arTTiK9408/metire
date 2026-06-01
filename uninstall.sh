#!/bin/sh
#
# Metire — uninstall.sh
# Usage: curl -sS https://raw.githubusercontent.com/arTTiK9408/metire/main/uninstall.sh | sh
#
# MIT License — https://github.com/arTTiK9408/metire

set -eu

BINARY="metire"
PATHS="/usr/local/bin /usr/bin $HOME/.local/bin $HOME/bin"

main() {
  need_cmd rm

  found=""
  for dir in $PATHS; do
    if [ -f "$dir/$BINARY" ]; then
      if [ -w "$dir" ]; then
        rm -f "$dir/$BINARY"
      elif command -v sudo >/dev/null 2>&1; then
        sudo rm -f "$dir/$BINARY"
      else
        err "need write access to $dir (try: sudo)"
      fi
      info "removed $dir/$BINARY"
      found=1
    fi
  done

  [ -z "$found" ] && info "metire not found — nothing to remove"
}

info()  { printf "\033[32mmetire\033[0m %s\n" "$*"; }
err()   { printf "\033[31mmetire\033[0m error: %s\n" "$*" >&2; exit 1; }
need_cmd() {
  command -v "$1" >/dev/null 2>&1 || err "required command '$1' not found"
}

main
