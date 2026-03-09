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
local apps_dir = home .. "/Apps"
local screenshots_dir = home .. "/Pictures/Screenshots"

if not command_ok("test -d " .. shell_quote(apps_dir)) then
  assert(command_ok("mkdir -p " .. shell_quote(apps_dir)), "failed to create Apps/")
  print("Create Apps/ directory.")
else
  print("Apps/ directory already exists.")
end

if not command_ok("test -d " .. shell_quote(screenshots_dir)) then
  assert(command_ok("mkdir -p " .. shell_quote(screenshots_dir)), "failed to create Screenshots/")
  print("Created Screenshots/ directory.")
else
  print("Screenshots/ directory already exists.")
end
