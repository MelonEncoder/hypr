# Dotfiles

Cross-platform dotfiles with shared config, OS-specific bootstrap, and Nix host definitions.

## Setup

Clone this repository into `~/.local/share/dotfiles`:

```bash
git clone [repo-url] ~/.local/share/dotfiles
cd ~/.local/share/dotfiles
```

## Layout

- `home/.config/`: user config (`nvim`, `hypr`, `quickshell`, `zed`, `fcitx5`, etc.)
- `home/.local/share/`: user local data (`wallpapers`, etc.)
- `platforms/archlinux/`: Arch Linux bootstrap (`setup.sh`, package lists, configure scripts) 
- `platforms/macos/`: macOS bootstrap (`setup.sh`)
- `platforms/nixos/`: NixOS bootstrap (`setup.sh`)
- `nix/hosts/`: per-machine NixOS configurations
- `nix/modules/`: shared NixOS and Home Manager modules

## Usage

### NixOS

Run the NixOS setup script with a host name. It will build and switch to the NixOS configuration, then symlink all user configs into place (with `.backup` suffixes on any existing files):

```bash
bash platforms/nixos/setup.sh <host>
```

Available hosts are listed in `nix/hosts/`. To list them:

```bash
bash platforms/nixos/setup.sh
```

To rebuild manually without symlinking configs:

```bash
sudo nixos-rebuild switch --flake .#<host>
```

### Arch Linux

Installs packages (pacman + AUR via yay + Flatpak), enables system services, configures user groups, locales, GTK/Qt theming, Rust toolchain, and symlinks all user configs:

```bash
bash platforms/archlinux/setup.sh
```

### macOS

Installs Homebrew if needed, then symlinks `nvim` and `zed` configs into `~/.config`. Existing directories are backed up to `~/.config/dotfiles-backups/<timestamp>/`:

```bash
zsh platforms/macos/setup.sh
```

## Notes

- Each host in `nix/hosts/` requires a `hardware-configuration.nix`. Generate one for your machine with:

```bash
sudo nixos-generate-config --show-hardware-config > \
  nix/hosts/<host>/hardware-configuration.nix
```

- The Arch Linux bootstrap is idempotent: already-installed packages and already-linked configs are skipped.
