#!/usr/bin/env bash
set -euo pipefail

ARCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$ARCH_DIR/../.."
SCRIPTS_DIR="$ARCH_DIR/scripts"
PKGS_DIR="$ARCH_DIR/pkgs"

echo "Installing packages..."
bash "$PKGS_DIR/install.sh"
echo "Package installation finished."

echo "Now configuring environment..."
bash "$SCRIPTS_DIR/enable_system_services.sh"
bash "$SCRIPTS_DIR/configure/groups.sh"
bash "$SCRIPTS_DIR/configure/locales.sh"
bash "$SCRIPTS_DIR/configure/pacman.sh"
bash "$SCRIPTS_DIR/configure/directories.sh"
bash "$SCRIPTS_DIR/configure/gtk.sh"
bash "$SCRIPTS_DIR/configure/qt.sh"
bash "$SCRIPTS_DIR/configure/rust.sh"
echo "Environment configuration finished."

echo "Linking config files..."
bash "$SCRIPTS_DIR/symlink_configs.sh" --repo "$REPO_ROOT"
echo "Config linking finished."
