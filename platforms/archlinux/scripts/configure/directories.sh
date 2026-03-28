#!/usr/bin/env bash
set -euo pipefail

APPS_DIR="$HOME/Apps"
SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
PROJECTS_DIR="$HOME/Projects"

if [ ! -d "$APPS_DIR" ]; then
  mkdir -p "$APPS_DIR"
  echo "Created Apps/ directory."
else
  echo "Apps/ directory already exists."
fi

if [ ! -d "$SCREENSHOTS_DIR" ]; then
  mkdir -p "$SCREENSHOTS_DIR"
  echo "Created Screenshots/ directory."
else
  echo "Screenshots/ directory already exists."
fi

if [ ! -d "$PROJECTS_DIR" ]; then
  mkdir -p "$PROJECTS_DIR"
  echo "Created Projects/ directory."
else
  echo "Projects/ directory already exists."
fi
