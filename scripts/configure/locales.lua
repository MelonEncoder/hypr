#!/usr/bin/env lua

local locales = {
  { code = "en_US", name = "English" },
  { code = "ja_JP", name = "Japanese" },
}

local function run_ok(cmd)
  local ok, _, code = os.execute(cmd)
  if type(ok) == "number" then
    return ok == 0
  end
  return ok == true and code == 0
end

local function run(cmd, err)
  if not run_ok(cmd) then
    error(err or ("command failed: " .. cmd))
  end
end

local function restore_backup()
  run_ok("sudo cp /etc/locale.gen.backup /etc/locale.gen")
  run_ok("sudo rm -f /etc/locale.gen.backup")
end

run("sudo cp /etc/locale.gen /etc/locale.gen.backup", "failed to create locale backup")

for _, item in ipairs(locales) do
  local code = item.code
  run(
    "sudo sed -i 's/^#\\(" .. code .. "\\.UTF-8 UTF-8\\)/\\1/' /etc/locale.gen",
    "failed updating /etc/locale.gen for " .. code
  )

  if run_ok("grep -q '^" .. code .. "\\.UTF-8 UTF-8' /etc/locale.gen") then
    print("Locale " .. code .. ".UTF-8 is successfully uncommented.")
  else
    print("<!> Error modifying locale.gen file.")
    restore_backup()
    os.exit(1)
  end
end

run("sudo locale-gen", "failed to run locale-gen")

for _, item in ipairs(locales) do
  if run_ok("locale -a | grep -q '^" .. item.code .. "\\.utf8$'") then
    print(item.name .. " locale successfully generated.")
  else
    print("<!> Error generating " .. item.name .. " locale.")
    restore_backup()
    os.exit(1)
  end
end

run("sudo rm /etc/locale.gen.backup", "failed to remove locale backup")
