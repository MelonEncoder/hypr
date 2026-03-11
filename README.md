# Dotfiles

Cross-platform dotfiles with shared config, OS-specific bootstrap, and Nix host definitions.

## Setup

Clone this repository into `~/.local/share/dotfiles`:

```bash
git clone [repo-url] ~/.local/share/dotfiles
cd ~/.local/share/dotfiles
```

## Layout

- `home/common/.config`: shared user config (`nvim`, etc.)
- `home/linux/.config`: Linux-only config (`hypr`, `quickshell`, etc.)
- `home/linux/.local/share`: Linux local data (`wallpapers`, etc.)
- `platforms/arch`: Arch bootstrap (`setup.lua`, package + configure scripts)
- `platforms/macos`: macOS bootstrap (`setup.sh`)
- `nix/hosts`: machine definitions for NixOS configuations
- `nix/home`: Home Manager modules (`common`, `linux`)
- `nix/modules`: reusable Nix modules

## Usage

### NixOS

```bash
sudo nixos-rebuild switch --flake .#[host]
```

### Arch Linux

Requires the installation of the lua package before you can run the command.

```bash
lua platforms/archlinux/setup.lua
```

### macOS

Installs Homebrew if needed, then links the shared user config into `~/.config`
with timestamped backups of any existing `nvim` or `zed` directories:

```bash
zsh platforms/macos/setup.sh
```

## Notes

- `nix/hosts/nixos/hardware-configuration.nix` is a placeholder if not already filled.
- Replace it with your hardware by using the command:

```bash
sudo nixos-generate-config --show-hardware-config
cp /etc/nixos/hardware-configuation.nix to ~/.local/share/dotfiles/nix/hosts/[host]/hardware-configuration.nix
```
