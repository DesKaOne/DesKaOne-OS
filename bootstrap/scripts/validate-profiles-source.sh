#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

bash -n scripts/validate-profiles-source.sh
bash scripts/validate-foundation-source.sh

for edition in desktop server; do
  for name in profile.conf packages.list.chroot; do
    file="profiles/$edition/$name"
    test -s "$file" || { printf 'Missing or empty: %s\n' "$file" >&2; exit 1; }
  done
  grep -Fxq "DESKAONE_EDITION=\"$edition\"" "profiles/$edition/profile.conf"
done

grep -Fxq 'DESKAONE_NETWORK_OWNER="NetworkManager"' profiles/desktop/profile.conf
grep -Fxq 'DESKAONE_NETWORK_OWNER="systemd-networkd"' profiles/server/profile.conf
grep -Fxq 'DESKAONE_SESSION="wayland"' profiles/desktop/profile.conf
grep -Fxq 'DESKAONE_DISPLAY_MANAGER="sddm"' profiles/desktop/profile.conf

for package in sddm plasma-desktop network-manager flatpak; do
  grep -Fxq "$package" profiles/desktop/packages.list.chroot || {
    printf 'Missing desktop candidate: %s\n' "$package" >&2; exit 1;
  }
done
grep -Fxq 'openssh-server' profiles/server/packages.list.chroot

# Profiles must not be accidentally promoted into the active live-build config.
shopt -s nullglob
active_lists=(config/package-lists/*.list.chroot)
(("${#active_lists[@]}" > 0)) || { echo 'No active package lists' >&2; exit 1; }
for package in sddm plasma-desktop network-manager flatpak openssh-server; do
  if grep -El "^[[:space:]]*${package}([[:space:]]*(#.*)?)?$" "${active_lists[@]}"; then
    printf 'Edition package unexpectedly active: %s\n' "$package" >&2
    exit 1
  fi
done
test ! -e config/includes.chroot/etc/deskaone/edition.conf || {
  echo 'Unexpected active edition selection' >&2; exit 1;
}
printf 'Bootstrap 03 source-only profile checks passed. No ISO, package resolution or boot validation performed.\n'
