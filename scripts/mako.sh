#!/bin/bash

CONFIG=~/.config/mako/config

launch() {
	killall mako
	mako -c $CONFIG &
}

launch
