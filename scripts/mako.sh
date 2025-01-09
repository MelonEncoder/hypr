#!/bin/bash

CONFIG=~/.config/hypr/mako/config

launch() {
	killall mako
	mako -c $CONFIG &
}

launch
