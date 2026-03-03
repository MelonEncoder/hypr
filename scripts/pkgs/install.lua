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

local function run(cmd)
  print(cmd)
  if not command_ok(cmd) then
    error("command failed: " .. cmd)
  end
end

local function command_exists(cmd)
  return command_ok("command -v " .. cmd .. " >/dev/null 2>&1")
end

local script = arg and arg[0] or "pkgs.lua"
local script_dir = script:match("^(.*)/[^/]+$") or "."
package.path = script_dir .. "/?.lua;" .. package.path

local pkgs = require("pkgs")

local pacman_order = {
  "applications",
  "fonts",
  "hyprland",
  "im",
  "programming",
  "themes",
  "utility",
}

local function pacman_exists(pkg)
  return command_ok("pacman -Si " .. shell_quote(pkg) .. " >/dev/null 2>&1")
end

local function pacman_installed(pkg)
  return command_ok("pacman -Qi " .. shell_quote(pkg) .. " >/dev/null 2>&1")
end

local function flatpak_installed(app)
  return command_ok("flatpak info " .. shell_quote(app) .. " >/dev/null 2>&1")
end

print("Checking pacman packages...")
local pacman_missing = {}
for _, group in ipairs(pacman_order) do
  for _, pkg in ipairs(pkgs.pacman_pkgs[group] or {}) do
    if pacman_exists(pkg) and not pacman_installed(pkg) then
      pacman_missing[#pacman_missing + 1] = pkg
      print("(+) adding '" .. pkg .. "'")
    end
  end
end

if #pacman_missing > 0 then
  run("sudo pacman -S --noconfirm " .. table.concat(pacman_missing, " "))
else
  print("No pacman packages to install.")
end

if not command_exists("yay") then
  print("(+) installing 'yay' from the AUR")
  run("tmp_dir=$(mktemp -d) && git clone https://aur.archlinux.org/yay.git \"$tmp_dir/yay\" && cd \"$tmp_dir/yay\" && makepkg -si --noconfirm && cd / && rm -rf \"$tmp_dir\"")
else
  print("AUR package 'yay' is already installed.")
end

print("Checking AUR packages...")
local aur_missing = {}
for _, pkg in ipairs(pkgs.aur_pkgs) do
  if pkg ~= "yay" and not pacman_installed(pkg) then
    aur_missing[#aur_missing + 1] = pkg
    print("(+) adding '" .. pkg .. "'")
  end
end

if #aur_missing > 0 then
  run("yay -S --noconfirm --needed " .. table.concat(aur_missing, " "))
else
  print("No AUR packages to install.")
end

if command_exists("flatpak") then
  run("flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo")

  print("Checking flatpak apps...")
  local flatpak_missing = {}
  for _, app in ipairs(pkgs.flatpak_pkgs) do
    if not flatpak_installed(app) then
      flatpak_missing[#flatpak_missing + 1] = app
      print("(+) adding '" .. app .. "'")
    end
  end

  if #flatpak_missing > 0 then
    run("flatpak install -y flathub " .. table.concat(flatpak_missing, " "))
  else
    print("No flatpak apps to install.")
  end
else
  print("flatpak is not installed; skipping flatpak apps.")
end
