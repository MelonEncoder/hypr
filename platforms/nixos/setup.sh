#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
data_dir="${XDG_DATA_HOME:-$HOME/.local/share}"
backup_suffix=".backup"

list_hosts() {
  find "$repo_root/nix/hosts" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
}

host_exists() {
  local candidate="$1"
  list_hosts | grep -Fxq "$candidate"
}

usage() {
  echo "Usage: $0 <host>"
  echo ""
  echo "Available hosts:"
  list_hosts | sed 's/^/  - /'
}

backup_and_link() {
  local src="$1"
  local dst="$2"
  local backup="${dst}${backup_suffix}"

  mkdir -p "$(dirname "$dst")"

  if [[ ! -e "$src" ]]; then
    echo "Skipping missing source: $src"
    return
  fi

  if [[ -L "$dst" ]]; then
    local current_target
    current_target="$(readlink "$dst")"
    if [[ "$current_target" == "$src" ]]; then
      echo "Already linked: $dst"
      return
    fi
  fi

  if [[ -e "$backup" || -L "$backup" ]]; then
    rm -rf "$backup"
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    mv "$dst" "$backup"
    echo "Backed up $dst -> $backup"
  fi

  ln -s "$src" "$dst"
  echo "Linked $dst -> $src"
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

host="$1"

if ! host_exists "$host"; then
  echo "Unknown host: $host"
  echo ""
  usage
  exit 1
fi

echo "Building NixOS configuration for $host..."
sudo nixos-rebuild switch --flake "$repo_root#$host"

backup_and_link "$repo_root/home/.config/fcitx5" "$config_dir/fcitx5"
backup_and_link "$repo_root/home/.config/hypr" "$config_dir/hypr"
backup_and_link "$repo_root/home/.config/nixpkgs" "$config_dir/nixpkgs"
backup_and_link "$repo_root/home/.config/nvim" "$config_dir/nvim"
backup_and_link "$repo_root/home/.config/quickshell" "$config_dir/quickshell"
backup_and_link "$repo_root/home/.config/zed" "$config_dir/zed"
backup_and_link "$repo_root/home/.local/share/wallpapers" "$data_dir/wallpapers"

echo "NixOS bootstrap complete."
