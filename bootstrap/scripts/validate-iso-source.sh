#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

bash -n scripts/validate-iso-source.sh
bash scripts/validate-profiles-source.sh

grep -Fq -- '--distribution trixie' scripts/prepare-build.sh
grep -Fq -- '--architectures amd64' scripts/prepare-build.sh
grep -Fq -- '--binary-images iso-hybrid' scripts/prepare-build.sh
grep -Fq -- '--debian-installer none' scripts/prepare-build.sh
grep -Fq 'lb build' scripts/build-iso.sh
grep -Fq 'sha256sum' scripts/build-iso.sh

for file in config/package-lists/deskaone-base.list.chroot \
            config/package-lists/deskaone-foundation.list.chroot \
            config/includes.chroot/etc/deskaone-release \
            config/includes.chroot/etc/deskaone/foundation.conf \
            ISO-04.md; do
  test -s "$file" || { printf 'Missing or empty: %s\n' "$file" >&2; exit 1; }
done

test ! -e config/includes.chroot/etc/deskaone/edition.conf || {
  echo 'Unexpected active edition selection' >&2
  exit 1
}
printf 'Bootstrap 04 source-only ISO readiness checks passed. No ISO build, package resolution or boot test performed.\n'
