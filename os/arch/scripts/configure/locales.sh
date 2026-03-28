#!/usr/bin/env bash
set -euo pipefail

locale_codes=(en_US ja_JP)
locale_names=(English Japanese)

restore_backup() {
  sudo cp /etc/locale.gen.backup /etc/locale.gen || true
  sudo rm -f /etc/locale.gen.backup || true
}

if ! sudo cp /etc/locale.gen /etc/locale.gen.backup; then
  echo "failed to create locale backup" >&2
  exit 1
fi

for i in "${!locale_codes[@]}"; do
  code="${locale_codes[$i]}"

  if ! sudo sed -i "s/^#\(${code}\.UTF-8 UTF-8\)/\1/" /etc/locale.gen; then
    echo "<!> failed updating /etc/locale.gen for $code" >&2
    restore_backup
    exit 1
  fi

  if grep -q "^${code}\.UTF-8 UTF-8" /etc/locale.gen; then
    echo "Locale ${code}.UTF-8 is successfully uncommented."
  else
    echo "<!> Error modifying locale.gen file." >&2
    restore_backup
    exit 1
  fi
done

if ! sudo locale-gen; then
  echo "failed to run locale-gen" >&2
  restore_backup
  exit 1
fi

for i in "${!locale_codes[@]}"; do
  code="${locale_codes[$i]}"
  name="${locale_names[$i]}"

  if locale -a | grep -q "^${code}\.utf8$"; then
    echo "$name locale successfully generated."
  else
    echo "<!> Error generating $name locale." >&2
    restore_backup
    exit 1
  fi
done

sudo rm /etc/locale.gen.backup
