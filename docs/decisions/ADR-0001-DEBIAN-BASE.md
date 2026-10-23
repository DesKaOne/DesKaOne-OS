# ADR-0001 — Debian Stable Foundation

**Status:** Accepted for architecture/documentation · **Date:** 2026-10-23

## Context
DesKaOne OS needs a maintainable base for Server, Network and KDE Desktop editions with upstream security maintenance.

## Decision
Use Debian Stable as the upstream base, APT/dpkg and systemd; prioritize official Debian packages. Follow Debian Stable security updates. Build AMD64 first and add ARM64 later. Organize DesKaOne-specific packages and edition configuration in one monorepo.

## Consequences
Reduced distribution maintenance relative to a full fork, but Debian package compatibility, upgrade testing, release-signing, firmware support and configuration ownership still require careful engineering.

## Scope
Architecture approval only. No implementation authorization.
