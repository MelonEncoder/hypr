#!/bin/bash

PACKAGE_DIR="$HOME/.config/hypr/packages"
PKGS=""

package_exists() {
    if pacman -Si $1 > /dev/null 2>&1; then
  		return 0
   	else
  		return 1
   	fi
}

package_installed() {
    if pacman -Qi $1 > /dev/null 2>&1; then
  		return 0
   	else
  		return 1
   	fi
}

echo "Checking packages..."

# Loop through all .txt files in the directory
for FILE in "$PACKAGE_DIR"/*.txt; do
    if [ -f "$FILE" ]; then
        while read -r LINE; do
            if package_exists "$LINE" && ! package_installed "$LINE"; then
                echo -e "(+) adding '$LINE'"
                PKGS="$PKGS $LINE"
            fi
        done < "$FILE"
    fi
done

if [ "$PKGS" != "" ]; then
    sudo pacman -S --noconfirm $PKGS
    echo "Package installation finished."
else
    echo "No packages to intstll."
fi
