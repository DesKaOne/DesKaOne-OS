#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
command -v lb >/dev/null || { echo "Missing live-build (lb)" >&2; exit 1; }
lb build 2>&1 | tee build.log
shopt -s nullglob
images=(live-image-*.iso)
((${#images[@]} > 0)) || { echo "No ISO produced" >&2; exit 1; }
sha256sum "${images[@]}" > SHA256SUMS
