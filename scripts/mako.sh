#!/bin/bash

CONFIG=~/.config/hypr/mako.conf

killall mako
mako -c $CONFIG &
