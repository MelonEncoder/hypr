#!/bin/bash

echo "Installing packages..."
./install/pacman/pkgs.sh
./install/aur/pkgs.sh
./install/flatpak/pkgs.sh
echo "Package installation finished."

echo "Now configuring environment..."
./configure/locales.sh
./configure/pacman.sh
./configure/dirs.sh
./configure/neovim.sh
