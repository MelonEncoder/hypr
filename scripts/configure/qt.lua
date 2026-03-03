#!/usr/bin/env lua

local function shell_quote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function command_ok(cmd)
  local ok, _, code = os.execute(cmd)
  if type(ok) == "number" then
    return ok == 0
  end
  return ok == true and code == 0
end

local home = os.getenv("HOME") or ""
local qt_dir = home .. "/.config/qt6ct"
local qt_conf = qt_dir .. "/qt6ct.conf"

assert(command_ok("mkdir -p " .. shell_quote(qt_dir)), "failed to create ~/.config/qt6ct")

if command_ok("test -f " .. shell_quote(qt_conf)) then
  print("qt6ct config already exists: " .. qt_conf)
  print("Leaving existing Qt settings unchanged.")
  os.exit(0)
end

local fh, err = io.open(qt_conf, "w")
if not fh then
  error("failed to write qt6ct config: " .. tostring(err))
end

fh:write([[
[Appearance]
icon_theme=breeze
style=Breeze
standard_dialogs=default
custom_palette=false
]])
fh:close()

print("Created default qt6ct config: " .. qt_conf)
