#!/bin/bash

## set GTK Themes, Icons, Cursor and Fonts

THEME="Adwaita"
CURSORS="WhiteSur-cursors"
ICONS="Adwaita"

apply() {
	#Theme
	gsettings set org.gnome.desktop.interface gtk-theme $THEME
	gsettings set org.gnome.desktop.interface gtk-application-prefer-dark-theme true
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
	
	#Cursors
	gsettings set org.gnome.desktop.interface cursor-theme $CURSORS
		
	#Icons
	gsettings set org.gnome.desktop.interface icon-theme $ICONS
}

apply
