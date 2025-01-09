#!/bin/bash

PACKAGE_FILE="../pkgs.txt"
PKGS=""
PKGS_AUR=""
AUR=0

package_installed() {
    if [ $AUR = 0 ]; then
        if pacman -Qi $1 > /dev/null 2>&1; then
    		return 0
    	else
    		return 1
    	fi
    elif [ $AUR = 1 ]; then
        if yay -Qi $1 > /dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    fi
}

package_exists() {
    if [ $AUR = 0 ]; then
        if pacman -Si $1 > /dev/null 2>&1; then
    		return 0
    	else
    		return 1
    	fi
    elif [ $AUR = 1 ]; then
        if yay -Si $1 > /dev/null 2>&1; then
            return 0
        else
            return 1
       	fi
    fi
}

echo "### PACKAGES ###"

while read LINE; do
    if [ "$LINE" = "[aur]" ]; then
        AUR=1
    fi

    FIRST=${LINE:0:1}
	if [ "$FIRST" = "[" ]; then
		echo "$LINE"
	elif [ "$LINE" = "" ]; then
		echo " "
	elif package_exists "$LINE" && [ $AUR = 0 ]; then
        if ! package_installed "$LINE"; then
            echo -e "(+) '$LINE' \t\tinstalling"
            PKGS+="$LINE "
    	fi
    elif package_exists "$LINE" && [ $AUR = 1 ]; then
        if ! package_installed "$LINE"; then
            echo -e "(+) '$LINE' \t\tinstalling"
            PKGS_AUR+="$LINE "
    	fi
    else
       echo -e "(!) '$LINE' \t\tdoes not exist"
    fi
done < $PACKAGE_FILE

echo "-------------------------------------"

if [ "$PKGS" != "" ]; then
    sudo pacman -S $PKGS
fi

if [ "$PKGS_AUR" != "" ]; then
    yay -S $PKGS_AUR
fi

echo "Packages installation complete."
