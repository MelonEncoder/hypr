#!/usr/bin/env bash
set -euo pipefail

apps_dir="$HOME/Apps"
screenshots_dir="$HOME/Pictures/Screenshots"

if [ ! -d "$apps_dir" ]; then
  mkdir -p "$apps_dir"
  echo "Created Apps/ directory."
else
  echo "Apps/ directory already exists."
fi

if [ ! -d "$screenshots_dir" ]; then
  mkdir -p "$screenshots_dir"
  echo "Created Screenshots/ directory."
else
  echo "Screenshots/ directory already exists."
fi
