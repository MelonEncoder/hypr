#!/bin/bash

CONFIG=~/.config/hypr/waybar/config/3/config.jsonc
STYLE=~/.config/hypr/waybar/config/3/style.css

launch_waybar() {
	killall waybar
	waybar -c $CONFIG -s $STYLE &
}

launch_waybar
