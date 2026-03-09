#!/usr/bin/env lua

local function expand_home(path)
  local home = os.getenv("HOME")
  if not home then
    return path
  end
  if path == "~" then
    return home
  end
  if path:sub(1, 2) == "~/" then
    return home .. path:sub(2)
  end
  return path
end

local function shell_quote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function run(cmd, dry_run)
  print(cmd)
  if dry_run then
    return
  end
  local ok = os.execute(cmd)
  if ok ~= true and ok ~= 0 then
    error("command failed: " .. cmd)
  end
end

local repo = "~/.local/share/dotfiles"
local dry_run = false

local i = 1
while i <= #arg do
  if arg[i] == "--repo" and arg[i + 1] then
    repo = arg[i + 1]
    i = i + 2
  elseif arg[i] == "--dry-run" then
    dry_run = true
    i = i + 1
  else
    error("unknown argument: " .. tostring(arg[i]))
  end
end

repo = expand_home(repo)
local config = expand_home("~/.config")
local local_share = expand_home("~/.local/share")

local mappings = {
  { repo .. "/home/linux/.config/hypr", config .. "/hypr" },
  { repo .. "/home/linux/.config/mako", config .. "/mako" },
  { repo .. "/home/common/.config/nvim", config .. "/nvim" },
  { repo .. "/home/linux/.config/quickshell", config .. "/quickshell" },
  { repo .. "/home/linux/.local/share/wallpapers", local_share .. "/wallpapers" },
  { repo .. "/home/linux/.config/wofi", config .. "/wofi" },
  { repo .. "/swps.conf", config .. "/swps.conf" },
}

print("repo: " .. repo)
print("config: " .. config)

for _, pair in ipairs(mappings) do
  local src, dst = pair[1], pair[2]
  local parent = dst:match("^(.*)/[^/]+$") or "."
  run("mkdir -p " .. shell_quote(parent), dry_run)
  run("rm -rf " .. shell_quote(dst), dry_run)
  run("ln -s " .. shell_quote(src) .. " " .. shell_quote(dst), dry_run)
end
