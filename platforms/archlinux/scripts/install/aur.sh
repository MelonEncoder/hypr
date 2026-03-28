#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../pkgs.sh"

pacman_installed() {
  pacman -Qi "$1" >/dev/null 2>&1
}

if ! command -v yay >/dev/null 2>&1; then
  echo "(+) installing 'yay' from the AUR"
  tmp_dir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"
  (cd "$tmp_dir/yay" && makepkg -si --noconfirm)
  rm -rf "$tmp_dir"
else
  echo "AUR package 'yay' is already installed."
fi

echo "Checking AUR packages..."
aur_missing=()
for pkg in "${aur_pkgs[@]}"; do
  if [ "$pkg" != "yay" ] && ! pacman_installed "$pkg"; then
    aur_missing+=("$pkg")
    echo "(+) adding '$pkg'"
  fi
done

if [ "${#aur_missing[@]}" -gt 0 ]; then
  yay -S --noconfirm --needed "${aur_missing[@]}"
else
  echo "No AUR packages to install."
fi
