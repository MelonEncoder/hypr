#!/usr/bin/env bash
set -euo pipefail

groups=("wheel" "dialout" "docker")

for group in "${groups[@]}"; do
  if id -nG "$USER" | grep -qw "$group"; then
    echo "User '$USER' is already in group '$group'."
  else
    sudo usermod -aG "$group" "$USER"
    echo "Added user '$USER' to group '$group'."
  fi
done
