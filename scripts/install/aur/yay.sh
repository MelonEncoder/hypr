#!/bin/bash

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
