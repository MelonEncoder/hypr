#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/pkgs.sh"

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

if command -v flatpak >/dev/null 2>&1; then
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

  echo "Checking flatpak apps..."
  flatpak_missing=()
  for app in "${flatpak_pkgs[@]}"; do
    if ! flatpak_installed "$app"; then
      flatpak_missing+=("$app")
      echo "(+) adding '$app'"
    fi
  done

  if [ "${#flatpak_missing[@]}" -gt 0 ]; then
    flatpak install -y flathub "${flatpak_missing[@]}"
  else
    echo "No flatpak apps to install."
  fi
else
  echo "flatpak is not installed; skipping flatpak apps."
fi
