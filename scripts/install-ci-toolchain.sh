#!/usr/bin/env bash
set -euo pipefail
root="${MOON_HOME:?MOON_HOME must point to an isolated toolchain directory}"
mkdir -p "$root/lib"
# Official 2026-10-12 snapshot. Use versioned objects, never moving latest URLs.
# SHA-256 pins archive identity; neither these pins nor ETags are vendor signatures.
curl --fail --location --retry 2 --header 'If-Match: "6ae7c52851085cc3d4d65fd04410ef7b-12"' \
  https://cli.moonbitlang.com/binaries/0.10.15%2B943464bfa/moonbit-linux-x86_64.tar.gz -o "$root/moonbit.tar.gz"
curl --fail --location --retry 2 --header 'If-Match: "65ef1811c0e64c48bf01312100f7e998"' \
  https://cli.moonbitlang.com/cores/core-0.10.15%2B943464bfa.tar.gz -o "$root/core.tar.gz"
printf '%s  %s\n' '24b93a5409d2a4fb8e3d1b84b473f27b63476cef4418094764df96cb26b03c09' "$root/moonbit.tar.gz" | sha256sum --check --status
printf '%s  %s\n' '96d30f4dbcc6a9e1736ef26fbdd0e8fb0e97cb01d50e55d2a0072208b8061ae5' "$root/core.tar.gz" | sha256sum --check --status
tar -xzf "$root/moonbit.tar.gz" -C "$root"
tar -xzf "$root/core.tar.gz" -C "$root/lib"
chmod +x "$root"/bin/*
export PATH="$root/bin:$PATH"
moon -C "$root/lib/core" bundle --warn-list -a --all
moon version --all
moon version --all | grep -F 'v0.10.15+943464bfa'
