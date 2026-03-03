#!/usr/bin/env bash

if [ "${1:-}" = "--toggle" ]; then
  if pgrep -x waybar >/dev/null 2>&1; then
    pkill -x waybar
    exit 0
  fi

  waybar >/dev/null 2>&1 &
  exit 0
fi

if pgrep -x waybar >/dev/null 2>&1; then
  pkill -x waybar
fi

waybar >/dev/null 2>&1 &
