#!/usr/bin/env lua

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

if not command_ok("command -v rustup >/dev/null 2>&1") then
  error("rustup is not installed. Install the 'rustup' package first.")
end

run("rustup default stable")
run("rustup target add wasm32-wasip1")
run("rustup component add rust-analyzer")

print("Rust toolchain configured.")
