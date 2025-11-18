#!/bin/bash

echo "Installing packages..."
./install/pacman/pkgs.sh
./install/aur/pkgs.sh
./install/flatpak/pkgs.sh
echo "Package installation finished."

echo "Now configuring environment..."
echo "||"
./configure/locales.sh
echo "||"
./configure/pacman.sh
echo "||"
./configure/dirs.sh
echo "||"
./configure/neovim.sh
