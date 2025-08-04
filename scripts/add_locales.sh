#!/bin/bash

locales=(
    "en_US"
    "ja_JP"
)
languages=(
    "English"
    "Japanese"
)

sudo cp /etc/locale.gen /etc/locale.gen.backup

for locale in "${locales[@]}"; do
    sudo sed -i 's/^#\('"$locale"'\.UTF-8 UTF-8\)/\1/' /etc/locale.gen

    if grep -q '^'"$locale"'\.UTF-8 UTF-8' /etc/locale.gen; then
        echo "Locale "$locale".UTF-8 is successfully uncommented."
    else
        echo "<!> Error modifying locale.gen file."
        sudo cp /etc/locale.gen.backup /etc/locale.gen
        sudo rm /etc/locale.gen.backup
        exit 1
    fi
done

sudo locale-gen

for ((i=0; i<${#locales[@]}; i++)); do
    if locale -a | grep -q '^'"${locales[$i]}"'\.utf8$'; then
        echo "${languages[$i]} locale successfully generated."
    else
        echo "<!> Error generating ${languages[$i]} locale."
        sudo cp /etc/locale.gen.backup /etc/locale.gen
        sudo rm /etc/locale.gen.backup
        exit 1
    fi
done

sudo rm /etc/locale.gen.backup
