#!/usr/bin/env bash

if pgrep -x mako >/dev/null 2>&1; then
  pkill -x mako
fi

mako >/dev/null 2>&1 &
