#!/bin/bash

CONFIG=~/.config/waybar/config_2/config.jsonc
STYLE=~/.config/waybar/config_2/style.css

launch_waybar() {
	killall waybar
	waybar -c $CONFIG -s $STYLE &
}

launch_waybar
