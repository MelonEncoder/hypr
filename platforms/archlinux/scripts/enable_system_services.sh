#!/usr/bin/env bash
set -euo pipefail

system_services=(
  NetworkManager.service
  ModemManager.service
  bluetooth.service
  cups.service
  docker.service
  power-profiles-daemon.service
  upower.service
  accounts-daemon.service
)

echo "Enabling system services..."
for service in "${system_services[@]}"; do
  sudo systemctl enable --now "$service"
  echo "  enabled $service"
done
