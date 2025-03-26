#!/bin/bash

CONFIG=~/.config/hypr/waybar/config/3/config.jsonc
STYLE=~/.config/hypr/waybar/config/3/style.css

ARG="$1"

load_waybar() {
	killall waybar
	waybar -c $CONFIG -s $STYLE &
}

toggle_waybar() {
	killall -SIGUSR1 waybar
}

if [[ $ARG == "--toggle" ]]; then
	toggle_waybar
else
	load_waybar
fi
