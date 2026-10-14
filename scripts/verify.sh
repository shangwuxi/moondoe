#!/usr/bin/env bash
set -euo pipefail
target="${1:-wasm-gc}"
case "$target" in wasm-gc|wasm|js|native) ;; *) echo 'unsupported target' >&2; exit 2 ;; esac
moon info --target "$target"
moon fmt --check
git diff --exit-code -- '*.mbti'
moon check --target "$target" --deny-warn
moon test --target "$target" --deny-warn
moon build --target "$target" --deny-warn
for example in screening response candidates; do
  moon run "examples/$example" --target "$target" --deny-warn
done
python3 scripts/audit.py
