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

mkdir -p "$HOME/.config/gtk-3.0"
cat > "$HOME/.config/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=$theme
gtk-application-prefer-dark-theme=true
gtk-icon-theme-name=$icons
gtk-cursor-theme-name=$cursors
gtk-cursor-theme-size=$cursor_size
EOF

mkdir -p "$HOME/.config/gtk-4.0"
cat > "$HOME/.config/gtk-4.0/settings.ini" <<EOF
[Settings]
gtk-application-prefer-dark-theme=true
gtk-icon-theme-name=$icons
gtk-cursor-theme-name=$cursors
gtk-cursor-theme-size=$cursor_size
EOF
