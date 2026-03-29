#!/usr/bin/env bash
set -euo pipefail

declare -A DIRS=(
  ["Desktop"]="$HOME/Desktop"
  ["Downloads"]="$HOME/Downloads"
  ["Documents"]="$HOME/Documents"
  ["Music"]="$HOME/Music"
  ["Pictures"]="$HOME/Pictures"
  ["Videos"]="$HOME/Videos"
  ["Templates"]="$HOME/Templates"
  ["Public"]="$HOME/Public"
  ["Screenshots"]="$HOME/Pictures/Screenshots"
  ["Apps"]="$HOME/Apps"
  ["Projects"]="$HOME/Projects"
)

for name in "${!DIRS[@]}"; do
  dir="${DIRS[$name]}"
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
    echo "Created $name/ directory."
  else
    echo "$name/ directory already exists."
  fi
done

xdg-user-dirs-update
