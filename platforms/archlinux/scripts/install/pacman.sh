#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../pkgs.sh"

pacman_exists() {
  pacman -Si "$1" >/dev/null 2>&1
}

pacman_installed() {
  pacman -Qi "$1" >/dev/null 2>&1
}

flatpak_installed() {
  flatpak info "$1" >/dev/null 2>&1
}

all_pacman_pkgs=(
  "${pacman_system[@]}"
  "${pacman_fonts[@]}"
  "${pacman_im[@]}"
  "${pacman_themes[@]}"
)

echo "Checking pacman packages..."
pacman_missing=()
for pkg in "${all_pacman_pkgs[@]}"; do
  if pacman_exists "$pkg" && ! pacman_installed "$pkg"; then
    pacman_missing+=("$pkg")
    echo "(+) adding '$pkg'"
  fi
done

if [ "${#pacman_missing[@]}" -gt 0 ]; then
  sudo pacman -S --noconfirm "${pacman_missing[@]}"
else
  echo "No pacman packages to install."
fi
