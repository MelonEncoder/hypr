#!/bin/bash

./install/packages.sh
./install/clipse.sh
./install/yay.sh

echo "Package installation finished.\n"

./add_locales.sh

./colorize_pacman.sh

./create_apps_dir.sh
