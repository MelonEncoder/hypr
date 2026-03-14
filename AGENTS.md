# Repository Guidelines

## Project Structure & Module Organization
- `home/.config/` stores shared user configuration, including `nvim/` and `nixpkgs/`.
- `home/.local/share/` contains user data assets such as wallpapers and other synced files.
- `platforms/archlinux/` holds Arch bootstrap logic: `setup.lua`, package definitions in `pkgs/`, and helper scripts in `scripts/`.
- `platforms/macos/setup.sh` bootstraps macOS and links shared config into `~/.config`.
- `nix/hosts/` defines host-specific NixOS machines; `nix/modules/` contains reusable NixOS and Home Manager modules.

## Build, Test, and Development Commands
- `sudo nixos-rebuild switch --flake .#<host>` applies a host configuration from `nix/hosts/`.
- `lua platforms/archlinux/setup.lua` runs the Arch Linux bootstrap flow.
- `zsh platforms/macos/setup.sh` installs macOS dependencies and links configs.
- `nix flake check` is the best general validation command for Nix changes when available in your environment.
- `git diff --stat` gives a quick sanity check before opening a PR.

## Coding Style & Naming Conventions
- Follow existing style per language: Nix, Lua, Shell, and Zsh all use the conventions already present in neighboring files.
- Use 2-space indentation in Nix files and keep attribute sets ordered when practical.
- Prefer descriptive lowercase file names such as `packages.nix`, `setup.lua`, and `symlink_configs.lua`.
- Keep host definitions under `nix/hosts/<machine-name>/` and place shared logic in `nix/modules/` rather than duplicating it.

## Testing Guidelines
- There is no dedicated automated test suite yet; validate changes with the narrowest relevant command for the target platform.
- For Nix edits, run `nix flake check` and, when applicable, `sudo nixos-rebuild build --flake .#<host>` before `switch`.
- For bootstrap scripts, test on the intended platform and confirm symlinks, packages, and generated backups behave correctly.
- Document any manual verification steps in the PR when automation is not possible.

## Commit & Pull Request Guidelines
- Recent commits use short, imperative messages like `added git config in nix` and `fixed bugs preventing quickshell from running`; keep that pattern, but prefer clear grammar.
- Keep commits focused on one change area and mention the affected platform or module when useful.
- PRs should include: a concise summary, impacted paths (for example `platforms/archlinux/`), manual test notes, and screenshots only for visual UI changes.

## Security & Configuration Tips
- Do not commit secrets, machine-specific tokens, or private keys.
- Treat `hardware-configuration.nix` as host-specific: update only the matching host directory and avoid copying values across machines blindly.
