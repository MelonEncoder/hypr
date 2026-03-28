# Repository Guidelines

## Project Structure & Module Organization
- `home/.config/` stores shared user configuration (e.g. `nvim/`, `hypr/`, `quickshell/`, `zed/`, `fcitx5/`).
- `home/.local/share/` contains user data assets such as wallpapers and other synced files.
- `platforms/archlinux/` holds Arch bootstrap logic: `setup.sh`, package installation in `pkgs/`, and helper scripts in `scripts/` (symlink configs, enable services, configure groups/locales/theming/rust).
- `platforms/macos/setup.sh` bootstraps macOS and links shared config into `~/.config`.
- `platforms/nixos/setup.sh` builds and switches to the NixOS configuration, then symlinks user configs.
- `platforms/nixos/nix/hosts/` defines host-specific NixOS machines; `platforms/nixos/nix/modules/` contains reusable NixOS and Home Manager modules.

## Build, Test, and Development Commands
- `sudo nixos-rebuild switch --flake .#<host>` applies a host configuration from `platforms/nixos/nix/hosts/`.
- `bash platforms/archlinux/setup.sh` runs the Arch Linux bootstrap flow.
- `zsh platforms/macos/setup.sh` installs macOS dependencies and links configs.
- `bash platforms/nixos/setup.sh <host>` builds and activates a NixOS host configuration.
- `nix flake check` is the best general validation command for Nix changes when available in your environment.

## Coding Style & Naming Conventions
- Follow existing style per language: Nix, Shell, and Zsh all use the conventions already present in neighboring files.
- Use 2-space indentation in Nix files and keep attribute sets ordered when practical.
- Prefer descriptive lowercase file names such as `packages.nix`, `setup.sh`, and `symlink_configs.sh`.
- Keep host definitions under `platforms/nixos/nix/hosts/<machine-name>/` and place shared logic in `platforms/nixos/nix/modules/` rather than duplicating it.

## Testing Guidelines
- There is no dedicated automated test suite yet; validate changes with the narrowest relevant command for the target platform.
- For Nix edits, run `nix flake check` and, when applicable, `sudo nixos-rebuild build --flake .#<host>` before `switch`.
- For bootstrap scripts, test on the intended platform and confirm symlinks, packages, and generated backups behave correctly.
- Document any manual verification steps in the PR when automation is not possible.

## Commit & Pull Request Guidelines
- Keep commit messages short and imperative; mention the affected platform or module when useful (e.g. `archlinux: add rust toolchain setup`).
- Keep commits focused on one change area.
- PRs should include: a concise summary, impacted paths, manual test notes, and screenshots only for visual UI changes.
- You may read git history (e.g. `git log`, `git show`) for context, but must not create, amend, rebase, push, or otherwise modify commits or branches.

## Security & Configuration Tips
- Do not commit secrets, machine-specific tokens, or private keys.
- `hardware-configuration.nix` is machine-generated and must never be edited. Treat it as read-only.
