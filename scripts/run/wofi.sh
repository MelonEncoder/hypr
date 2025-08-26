#!/bin/bash

CONFIG=~/.config/hypr/wofi/config
STYLE=~/.config/hypr/wofi/style.css
COLORS=~/.cofig/hypr/wofi/colors

launch() {
	killall wofi
	wofi -c $CONFIG -s $STYLE
}

launch
