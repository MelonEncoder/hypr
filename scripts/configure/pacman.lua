#!/usr/bin/env lua

local function run_ok(cmd)
  local ok, _, code = os.execute(cmd)
  if type(ok) == "number" then
    return ok == 0
  end
  return ok == true and code == 0
end

if not run_ok("sudo cp /etc/pacman.conf /etc/pacman.conf.backup") then
  print("<!> Failed to create backup")
  os.exit(1)
end

run_ok("sudo sed -i 's/^#\\([[:space:]]*\\)Color[[:space:]]*$/Color/' /etc/pacman.conf")

if not run_ok("grep -q '^Color$' /etc/pacman.conf") then
  print("<!> Error uncommenting Color property in /etc/pacman.conf")
  if not run_ok("sudo cp /etc/pacman.conf.backup /etc/pacman.conf") then
    print("<!> Failed to restore backup")
    os.exit(1)
  end
  print("<!> Keeping backup for investigation")
  os.exit(1)
end

if run_ok("test -f /etc/pacman.conf.backup") then
  run_ok("sudo rm /etc/pacman.conf.backup")
else
  print("<!> Warning: Backup file not found during cleanup")
end

print("Successfully updated pacman to support colors.")
