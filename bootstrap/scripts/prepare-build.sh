#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command -v lb >/dev/null || { echo "Missing live-build (lb)" >&2; exit 1; }
cd "$ROOT"
lb config --distribution trixie --architectures amd64 \
  --binary-images iso-hybrid --debian-installer none \
  --archive-areas main \
  --mirror-bootstrap https://deb.debian.org/debian/ \
  --mirror-chroot https://deb.debian.org/debian/ \
  --mirror-binary https://deb.debian.org/debian/
echo "live-build configuration prepared."
