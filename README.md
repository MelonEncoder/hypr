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
- `os/arch/`: Arch Linux bootstrap (`setup.sh`, package lists, configure scripts) 
- `os/macos/`: macOS bootstrap (`setup.sh`)
- `os/nixos/`: NixOS bootstrap (`setup.sh`, host configs, modules)

## Usage

### NixOS

Run the NixOS setup script with a host name. It will build and switch to the NixOS configuration, then symlink all user configs into place (with `.backup` suffixes on any existing files):

```bash
bash os/nixos/setup.sh <host>
```

Available hosts are listed in `os/nixos/nix/hosts/`. To list them:

```bash
bash os/nixos/setup.sh
```

To rebuild manually without symlinking configs:

```bash
sudo nixos-rebuild switch --flake .#<host>
```

### Arch Linux

Installs packages (pacman + AUR via yay + Flatpak), enables system services, configures user groups, locales, GTK/Qt theming, Rust toolchain, and symlinks all user configs:

```bash
bash os/archlinux/setup.sh
```

### macOS

Installs Homebrew if needed, then symlinks `nvim` and `zed` configs into `~/.config`. Existing directories are backed up to `~/.config/dotfiles-backups/<timestamp>/`:

```bash
zsh os/macos/setup.sh
```

## Notes

- Each host in `os/nixos/nix/hosts/` requires a `hardware-configuration.nix`. Generate one for your machine with:

```bash
sudo nixos-generate-config --show-hardware-config > \
  os/nixos/nix/hosts/<host>/hardware-configuration.nix
```

- The Arch Linux bootstrap is idempotent: already-installed packages and already-linked configs are skipped.
