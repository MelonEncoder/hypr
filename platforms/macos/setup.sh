#!/usr/bin/env zsh

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
backup_root="${config_dir}/dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
created_backup_root=0

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    echo "Homebrew already installed."
    return
  fi

  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

link_config() {
  local name="$1"
  local src="$repo_root/home/common/.config/$name"
  local dst="$config_dir/$name"

  mkdir -p "$config_dir"

  if [[ ! -e "$src" ]]; then
    echo "Skipping $name: source not found at $src"
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

  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ $created_backup_root -eq 0 ]]; then
      mkdir -p "$backup_root"
      created_backup_root=1
    fi
    mv "$dst" "$backup_root/$name"
    echo "Backed up $dst to $backup_root/$name"
  fi

  ln -s "$src" "$dst"
  echo "Linked $dst -> $src"
}

ensure_homebrew
link_config "nvim"
link_config "zed"

echo "macOS dotfiles setup complete."
