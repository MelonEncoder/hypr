#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../pkgs.sh"

flatpak_installed() {
  flatpak info "$1" >/dev/null 2>&1
}

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
