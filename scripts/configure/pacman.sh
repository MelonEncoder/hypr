#!/bin/bash

if ! sudo cp /etc/pacman.conf /etc/pacman.conf.backup; then
    echo "<!> Failed to create backup: $?"
    exit 1
fi

sudo sed -i 's/^#\([[:space:]]*\)Color[[:space:]]*$/Color/' /etc/pacman.conf

if ! grep -q '^Color$' /etc/pacman.conf; then
    echo "<!> Error uncommenting Color property in /etc/pacman.conf"
    if ! sudo cp /etc/pacman.conf.backup /etc/pacman.conf; then
        echo "<!> Failed to restore backup: $?"
        exit 1
    fi
    echo "<!> Keeping backup for investigation"
    exit 1
fi

if [ -f /etc/pacman.conf.backup ]; then
    sudo rm /etc/pacman.conf.backup
else
    echo "<!> Warning: Backup file not found during cleanup"
fi

echo "Successfully updated pacman to support colors."
