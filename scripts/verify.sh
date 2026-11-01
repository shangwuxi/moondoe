#!/usr/bin/env bash
set -euo pipefail
target="${1:-wasm-gc}"
case "$target" in wasm-gc|wasm|js|native) ;; *) echo 'unsupported target' >&2; exit 2 ;; esac
# minimum_moonc: acceptance requires moonc >= 0.10.16.
moon version --all | python3 -c 'import re, sys; s=sys.stdin.read(); m=re.search(r"moonc v(\d+)\.(\d+)\.(\d+)", s); ok=m is not None and tuple(map(int, m.groups())) >= (0, 10, 16); print(s, end=""); sys.exit(0 if ok else "moonc >= 0.10.16 is required")'
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
