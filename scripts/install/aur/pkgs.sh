#!/bin/bash

# YAY
if ! command -v yay $>/dev/null; then
    echo "(+) installing 'yay' from the AUR"
	cd /tmp
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si
	cd ..
	rm -rf yay
	cd ~
else
    echo "AUR package 'yay' is already installed."
fi

# CLIPSE
if ! command -v clipse $>/dev/null; then
    echo "(+) installing 'clipse' from the AUR"
	yay -S clipse
else
    echo "AUR package 'clipse' is already installed."
fi

# HYPRLAUNCHER
if ! command -v hyprlauncher $>/dev/null; then
    echo "(+) installing 'clipse' from the AUR"
	yay -S hyprlauncher
else
    echo "AUR package 'clipse' is already installed."
fi
