#!/usr/bin/env lua

local function shell_quote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function run(cmd)
  print(cmd)
  local ok = os.execute(cmd)
  if ok ~= true and ok ~= 0 then
    error("command failed: " .. cmd)
  end
end

local script = arg and arg[0] or "setup.lua"
local repo_dir = script:match("^(.*)/[^/]+$") or "."
local scripts_dir = repo_dir .. "/scripts"

print("Installing packages...")
run("lua " .. shell_quote(scripts_dir .. "/pkgs/install.lua"))
print("Package installation finished.")

print("Now configuring environment...")
run("lua " .. shell_quote(scripts_dir .. "/configure/locales.lua"))
run("lua " .. shell_quote(scripts_dir .. "/configure/pacman.lua"))
run("lua " .. shell_quote(scripts_dir .. "/configure/directories.lua"))
run("lua " .. shell_quote(scripts_dir .. "/configure/gtk.lua"))
run("lua " .. shell_quote(scripts_dir .. "/configure/qt.lua"))
run("lua " .. shell_quote(scripts_dir .. "/configure/rust.lua"))
print("Environment configuration finished.")

print("Linking config files...")
run("lua " .. shell_quote(scripts_dir .. "/symlink_configs.lua") .. " --repo " .. shell_quote(repo_dir))
print("Config linking finished.")
