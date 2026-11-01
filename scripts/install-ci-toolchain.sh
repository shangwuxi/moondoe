#!/usr/bin/env bash
set -euo pipefail
root="${MOON_HOME:?MOON_HOME must point to an isolated toolchain directory}"
mkdir -p "$root/lib"
# Official 2026-10-28 snapshot. Use versioned objects, never moving latest URLs.
# SHA-256 pins archive identity; neither these pins nor ETags are vendor signatures.
curl --fail --location --retry 2 --header 'If-Match: "0560ebd5ba5528390cd4872766f2234b"' \
  https://cli.moonbitlang.com/binaries/0.10.18%2B6c83a7f62/moonbit-linux-x86_64.tar.gz -o "$root/moonbit.tar.gz"
curl --fail --location --retry 2 --header 'If-Match: "7b87b77b0d942a76fba657b809c31cdf"' \
  https://cli.moonbitlang.com/cores/core-0.10.18%2B6c83a7f62.tar.gz -o "$root/core.tar.gz"
printf '%s  %s\n' '0e4cde1ace98e8ef00552a937738b59c6901c4b8a004ebad71ea0e63688f63f1' "$root/moonbit.tar.gz" | sha256sum --check --status
printf '%s  %s\n' '30a8ae1c1e1e8fde478ea742cbc928c8f4ae1f5c00090afe3f10c97be9e5da64' "$root/core.tar.gz" | sha256sum --check --status
tar -xzf "$root/moonbit.tar.gz" -C "$root"
tar -xzf "$root/core.tar.gz" -C "$root/lib"
chmod +x "$root"/bin/*
export PATH="$root/bin:$PATH"
moon -C "$root/lib/core" bundle --warn-list -a --all
moon version --all
moon version --all | grep -F 'v0.10.18+6c83a7f62'
