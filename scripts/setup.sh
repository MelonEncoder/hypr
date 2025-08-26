#!/bin/bash

./install/packages.sh
./install/aur/clipse.sh
./install/aur/yay.sh

echo "Package installation finished.\n"

./configure/locales.sh
./configure/pacman.sh
./configure/apps_dir.sh
