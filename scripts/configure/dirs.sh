#!/bin/bash

if [ ! -d "$HOME/Apps" ]; then
    mkdir -p "$HOME/Apps"
    echo "Create Apps/ directory."
else
    echo "Apps/ directory already exists."
fi

if [ ! -d "$HOME/Pictures/Screenshots" ]; then
	mkdir -p "$HOME/Pictures/Screenshots"
	echo "Created Screenshots/ directory."
else
	echo "Screenshots/ directory already exists."
fi
