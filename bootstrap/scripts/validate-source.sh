#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
for script in scripts/prepare-build.sh scripts/build-iso.sh scripts/validate-source.sh; do
  bash -n "$script"
  printf 'OK syntax: %s\n' "$script"
done
for required in config/package-lists/deskaone-base.list.chroot config/includes.chroot/etc/deskaone-release; do
  test -s "$required" || { printf 'Missing or empty: %s\n' "$required" >&2; exit 1; }
  printf 'OK file: %s\n' "$required"
done
grep -qx 'DESKAONE_ARCH="amd64"' config/includes.chroot/etc/deskaone-release
grep -qx 'DESKAONE_BASE="Debian 13 Trixie"' config/includes.chroot/etc/deskaone-release
grep -qx 'linux-image-amd64' config/package-lists/deskaone-base.list.chroot
printf 'Bootstrap 01 source-only checks passed. No ISO build or VM boot performed.\n'
