# Dotfiles

Cross-platform dotfiles with shared config, OS-specific bootstrap, and Nix host definitions.

## Layout

- `home/common/.config`: shared user config (currently `nvim`)
- `home/linux/.config`: Linux-only config (`hypr`, `wofi`, etc.)
- `home/linux/.local/share`: Linux local data (`wallpapers`)
- `platforms/arch`: Arch bootstrap (`setup.lua`, package + configure scripts)
- `platforms/nixos`: NixOS bootstrap entrypoints
- `platforms/macos`: macOS bootstrap entrypoints
- `nix/hosts`: machine definitions (NixOS / nix-darwin style)
- `nix/home`: Home Manager modules (`common`, `linux`, `darwin`)
- `nix/modules`: reusable Nix modules

## Usage

### Arch

```bash
lua platforms/arch/setup.lua
```

### NixOS (from this repo)

```bash
sudo nixos-rebuild switch --flake .#nixos
```

Or use:

```bash
./platforms/nixos/bootstrap.sh
```

### Home Manager (non-NixOS Linux)

```bash
home-manager switch --flake .#ian@arch
```

## Notes

- `nix/hosts/nixos/hardware-configuration.nix` is a placeholder.
- Replace it using output from:

```bash
sudo nixos-generate-config --show-hardware-config
```
