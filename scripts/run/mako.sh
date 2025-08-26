#!/bin/bash

CONFIG=~/.config/hypr/mako/config

killall mako
mako -c $CONFIG &
