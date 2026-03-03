#!/usr/bin/env lua

local function run(cmd)
  print(cmd)
  local ok, _, code = os.execute(cmd)
  if type(ok) == "number" then
    ok = ok == 0
  else
    ok = ok == true and code == 0
  end
  if not ok then
    error("command failed: " .. cmd)
  end
end

local theme = "Adwaita"
local cursors = "Adwaita"
local cursor_size = 22
local icons = "Adwaita"

run("gsettings set org.gnome.desktop.interface gtk-theme " .. theme)
run("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
run("gsettings set org.gnome.desktop.interface cursor-theme " .. cursors)
run("gsettings set org.gnome.desktop.interface cursor-size " .. tostring(cursor_size))
run("gsettings set org.gnome.desktop.interface icon-theme " .. icons)
