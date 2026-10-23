# Update Policy — Design

**Status:** Design only.

- Upstream: Debian Stable, Debian Security and Stable Updates.
- DesKaOne packages: signed stable and pre-release testing channels; do not confuse with Debian Testing.
- Server: controlled security upgrades, reboot with administrator coordination.
- Network: staged upgrades, backup, service health checks and documented recovery.
- Desktop: visible updates and user-controlled reboot.
- Major Debian upgrades: only after compatibility and migration testing.
- Release artifacts: manifest, checksums, signature, known issues and recovery guidance.
- Network configuration rollback is required for MVP; atomic whole-system rollback is a future design topic.

No automated release or update infrastructure is implemented.
