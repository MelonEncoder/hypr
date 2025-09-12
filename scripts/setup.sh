#!/bin/bash

./install/packages.sh
./install/aur/clipse.sh
./install/aur/yay.sh

echo "Package installation finished."
echo "||"

./configure/locales.sh

echo "||"

./configure/pacman.sh

echo "||"

./configure/dirs.sh
