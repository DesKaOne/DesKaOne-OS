#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

bash -n scripts/validate-validation-source.sh
bash scripts/validate-iso-source.sh

test -s VALIDATION-05.md || { echo 'Missing validation plan' >&2; exit 1; }
for gate in SRC-01 SRC-02 PKG-01 PKG-02 BLD-01 BLD-02 BOOT-01 BOOT-02 SEC-01 NET-01 OPS-01 EDT-01 REC-01; do
  grep -Fq "| $gate |" VALIDATION-05.md || {
    printf 'Missing validation gate: %s\n' "$gate" >&2
    exit 1
  }
done
grep -Fq 'Not executed' VALIDATION-05.md
grep -Fq 'future approval' VALIDATION-05.md
printf 'Bootstrap 05 source-only validation plan checks passed. No build, dependency resolution or VM test performed.\n'
