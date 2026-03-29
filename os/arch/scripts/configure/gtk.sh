#!/usr/bin/env bash
set -euo pipefail

theme="Adwaita-dark"
cursors="Adwaita"
cursor_size=22
icons="Adwaita"

gsettings set org.gnome.desktop.interface gtk-theme "$theme"
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface cursor-theme "$cursors"
gsettings set org.gnome.desktop.interface cursor-size "$cursor_size"
gsettings set org.gnome.desktop.interface icon-theme "$icons"

