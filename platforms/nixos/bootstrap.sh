#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

if ! command -v nix >/dev/null 2>&1; then
  echo "Nix is not installed. Install it first: https://nixos.org/download/"
  exit 1
fi

echo "Applying NixOS configuration from flake..."
sudo nixos-rebuild switch --flake "${REPO_ROOT}#nixos"
