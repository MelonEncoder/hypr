#!/bin/bash

if [ ! -d "$HOME/Apps" ]; then
    mkdir "$HOME/Apps"
    echo "Create Apps directory."
else
    echo "Apps directory already exists."
fi
