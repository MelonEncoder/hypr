#!/bin/bash

if ! command -v clipse $>/dev/null; then
    echo "(+) installing 'clipse' from the AUR"
	cd /tmp
	git clone https://aur.archlinux.org/clipse.git
	cd clipse
	makepkg -si
	cd ..
	rm -rf clipse
	cd ~
else
    echo "AUR package 'clipse' is already installed."
fi
