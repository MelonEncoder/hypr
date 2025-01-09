#!/bin/bash

CONFIG=~/.config/wofi/config
STYLE=~/.config/wofi/style.css
COLORS=~/.cofig/wofi/colors

launch() {
	killall wofi
	wofi -c $CONFIG -s $STYLE
}

launch
