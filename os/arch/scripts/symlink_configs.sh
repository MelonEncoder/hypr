#!/usr/bin/env bash
set -euo pipefail

repo="$HOME/.local/share/dotfiles"

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      repo="$2"
      shift 2
      ;;
    --dry-run)
      dry_run=true
      shift
      ;;
    *)
      echo "unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

config="$HOME/.config"
local_share="$HOME/.local/share"

echo "repo: $repo"
echo "config: $config"

mappings=(
  "$repo/home/.config/fcitx5|$config/fcitx5"
  "$repo/home/.config/gtk-3.0|$config/gtk-3.0"
  "$repo/home/.config/gtk-4.0|$config/gtk-4.0"
  "$repo/home/.config/hypr|$config/hypr"
  "$repo/home/.config/nvim|$config/nvim"
  "$repo/home/.config/qt6ct|$config/qt6ct"
  "$repo/home/.config/quickshell|$config/quickshell"
  "$repo/home/.config/zed|$config/zed"
  "$repo/home/.local/share/wallpapers|$local_share/wallpapers"
)

for mapping in "${mappings[@]}"; do
  src="${mapping%%|*}"
  dst="${mapping##*|}"
  parent="$(dirname "$dst")"
  mkdir -p "$parent"
  rm -rf "$dst"
  ln -s "$src" "$dst"
done
