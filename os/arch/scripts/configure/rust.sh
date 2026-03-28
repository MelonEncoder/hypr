#!/usr/bin/env bash
set -euo pipefail

if ! command -v rustup >/dev/null 2>&1; then
  echo "rustup is not installed. Install the 'rustup' package first." >&2
  exit 1
fi

rustup default stable
rustup target add wasm32-wasip1
rustup component add rust-analyzer

echo "Rust toolchain configured."
