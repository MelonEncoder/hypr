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

local function capture(cmd)
  local handle = assert(io.popen(cmd))
  local output = handle:read("*a") or ""
  handle:close()
  return output:gsub("%s+$", "")
end

local function run(cmd)
  print(cmd)
  if not command_ok(cmd) then
    error("command failed: " .. cmd)
  end
end

local services = {
  "NetworkManager.service",
  "ModemManager.service",
  "bluetooth.service",
  "cups.service",
  "power-profiles-daemon.service",
}

for _, service in ipairs(services) do
  if not command_ok("systemctl list-unit-files --type=service " .. shell_quote(service) .. " >/dev/null 2>&1") then
    print("Skipping " .. service .. " because it is not installed.")
  else
    local state = capture("systemctl is-enabled " .. shell_quote(service) .. " 2>/dev/null || true")
    if state == "enabled" then
      print(service .. " is already enabled.")
    else
      run("sudo systemctl enable --now " .. shell_quote(service))
      print("Enabled and started " .. service .. ".")
    end
  end
end
