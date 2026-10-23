# Server Edition — Design Specification

**Status:** Design only. Implementation not authorized.

## Purpose
Headless Debian Stable-based system for VPS, bare metal and homelabs.

## Planned baseline
OpenSSH, systemd-networkd, nftables, journald, APT/dpkg and common security profile. Docker/Podman, PostgreSQL, Nginx/Caddy, Go and monitoring are opt-in profiles.

## Security
No direct SSH root login by default; least-privilege users; deny unauthorized inbound traffic; no services exposed solely by installing optional packages.

## Acceptance gates
Clean AMD64 install/boot, authenticated SSH, persistent network/firewall, security updates, safe reboot/recovery and measured idle resource use.

## Open decisions
Installer, cloud image formats, default storage profile, optional workload presets.
