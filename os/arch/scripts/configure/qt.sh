#!/usr/bin/env bash
set -euo pipefail

qt_dir="$HOME/.config/qt6ct"
qt_conf="$qt_dir/qt6ct.conf"

mkdir -p "$qt_dir"

if [ -f "$qt_conf" ]; then
  echo "qt6ct config already exists: $qt_conf"
  echo "Leaving existing Qt settings unchanged."
  exit 0
fi

cat > "$qt_conf" << 'EOF'
[Appearance]
icon_theme=breeze
style=Breeze
standard_dialogs=default
custom_palette=false
EOF

echo "Created default qt6ct config: $qt_conf"
