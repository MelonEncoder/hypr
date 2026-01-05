#!/bin/bash

CONF_DIR="$HOME/.config/nvim/"

if [ ! -d "$CONF_DIR" ]; then
	mkdir -p $CONF_DIR
	git clone https://github.com/MelonEncoder/nvim.git $CONF_DIR
	echo "Created neovim config directory."
else
	echo "Neovim config directory already exists."
fi
