#!/bin/bash

## set GTK Themes, Icons, Cursor and Fonts

THEME="Adwaita"
CURSORS="Adwaita"
CURSOR_SIZE=22
ICONS="Adwaita"

apply() {
	#Theme
	gsettings set org.gnome.desktop.interface gtk-theme $THEME
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
	
	#Cursors
	gsettings set org.gnome.desktop.interface cursor-theme $CURSORS
	gsettings set org.gnome.desktop.interface cursor-size $CURSOR_SIZE
		
	#Icons
	gsettings set org.gnome.desktop.interface icon-theme $ICONS
}

apply
