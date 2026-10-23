# DesKaOne OS — Architecture v0.1

**Status:** Approved for documentation only · **Revision:** Final Draft R1 consolidated · **Repository:** `DesKaOne/DesKaOne-OS`

## Vision and scope

DesKaOne OS is a Debian Stable-based distribution family with three editions: Server (headless hosting), Network (router/gateway/firewall/VPN/proxy), and Desktop (KDE Plasma workstation). It is a Debian derivative, **not** a from-scratch kernel or independent replacement for Debian packaging.

No implementation, ISO, installable package or release is approved or available.

## Approved decisions

| Topic | Decision |
| --- | --- |
| Upstream | Debian Stable; follow Debian security updates |
| Source organization | One monorepo, modular edition boundaries |
| Editions | Server, Network, Desktop |
| Desktop | KDE Plasma |
| Network administration | Web dashboard + CLI |
| Initial CPU architecture | AMD64 |
| Later CPU architecture | ARM64 |
| Init and packaging | systemd, APT/dpkg, Debian-provided kernel |
| Release policy | Debian Stable-aligned, with DesKaOne testing/stable package channels |

The exact Debian codename for the first build is frozen only when the release baseline is approved.

## Design principles

1. Prefer Debian packages and security maintenance; minimize upstream forks.
2. Shared core with edition-specific metapackages and configuration ownership.
3. Minimal services and least privilege by default.
4. Reproducible, isolated builds with traceable manifests and tests.
5. Signed repositories and artifacts before public distribution.
6. No hidden cross-edition dependencies or mandatory optional ecosystem integrations.
7. Explicit architecture governance and phase-by-phase implementation approval.

## Planned monorepo

`docs/` documentation and ADRs; `configs/` common and edition profiles; `packages/` package definitions; `components/` DesKaOne utilities; `images/` edition images; `build/` orchestration; `tests/` verification; `.github/workflows/` future CI. Paths outside `docs/` are proposals only.

## Shared platform

Debian Linux kernel and userland, systemd, APT/dpkg, release identity, security baseline, logging, package/update policy, diagnostics and edition metadata.

Proposed packages: `deskaone-core`, `deskaone-release`, `deskaone-security`, `deskaone-server`, `deskaone-network`, `deskaone-desktop`, `deskaone-network-admin`, `deskaone-tools`. Names and packaging details are not yet implemented.

Use Debian's native configuration conventions. Avoid overriding user configuration on upgrades. Keep Debian attribution and compatibility metadata accurate.

## Server edition

Headless, OpenSSH, nftables, systemd-networkd and journald. Containers, PostgreSQL, web servers and development tools are optional profiles. Default services must not be publicly exposed without deliberate configuration. Acceptance: installation/boot, SSH access, firewall baseline, reboot persistence, package updates and recovery on supported AMD64 targets.

## Network edition

Linux routing/iproute2, nftables/NAT, WireGuard, selected DNS/DHCP backend and versioned intended configuration. A Go + HTML templates + HTMX web UI and CLI use one validated management service; privileged system changes pass through a narrowly scoped executor. The web process must not run as unrestricted root.

Management access is authenticated, CSRF-protected and bound to explicitly authorized interfaces. Separate management and data planes. Sensitive changes are audited. No open proxy or WAN administration by default.

Connectivity-sensitive changes follow **validate → save known-good → apply candidate → health check → confirm or automatic rollback**. Recovery must remain possible if remote access is lost. DesKaOne ProxyHub, Proxy Rotator and Control Center are optional integrations, not prerequisites.

Acceptance: routing/NAT, firewall persistence, VPN, authenticated management, CLI/web parity, rollback after failed change, reboot recovery and performance/resource benchmarks.

## Desktop edition

KDE Plasma, SDDM, Wayland target, PipeWire, NetworkManager, graphical APT-compatible software management. Developer tools (Git, Go, Flutter/Dart, container tools, editors) are optional. Acceptance: graphical login, networking/audio/storage, updates, display compatibility and suspend/resume where supported.

## Networking ownership

Server and Network target systemd-networkd; Desktop uses NetworkManager. Never let two managers concurrently own the same interface. Routing/DNS/firewall changes require integration tests.

## Installation and images

AMD64-first image targets for Server, Network and Desktop. Debian debootstrap/live-build and installer tooling are candidates, not selected implementations. UEFI is targeted first; legacy BIOS is a compatibility goal where practical. Secure Boot requires separate signing design. ARM64 follows later, with generic UEFI testing distinct from board-specific firmware/bootloader validation.

ext4 is an initial filesystem candidate, not a locked partitioning design.

## Packages and updates

Use Debian Stable, Stable Security and Stable Updates, plus signed DesKaOne stable/testing channels. DesKaOne testing is **not** Debian Testing. Do not disable signature validation or mix unstable Debian packages casually.

Server: controlled security updates and planned reboots. Network: staged updates, backup, health checks and recovery. Desktop: user-visible updates and reboot control. Major Debian upgrades require tested migration plans. Configuration rollback is required for Network MVP; whole-system atomic rollback is not.

## Security and release

Least privilege, protected admin sessions, CSRF/rate limits, audit, signed repository metadata, protected signing keys, provenance and checksums. Each release records Debian baseline, DesKaOne version, edition, architecture, package manifest, test evidence, known issues and recovery guidance. A successful image build is not a production release.

## Tests and observability

Common: package install/remove, boot, upgrade, dependency integrity, security baseline, recovery. Server: SSH/firewall/services. Network: routing, NAT, VPN, auth, rollback, performance. Desktop: KDE login, network/audio/display and updates. Shared Core changes require cross-edition impact assessment. Use journald and structured application logs; telemetry must not send data externally without explicit approval.

## Out of initial scope

Custom kernel, replacement package manager, large Debian fork, universal SBC support, custom software center, router HA, atomic whole-OS rollback and mandatory DesKaOne application integrations.

## Open decisions

Installer framework; partition/filesystem policy; Secure Boot trust chain; network config persistence and privileged executor implementation; dashboard authentication specifics; update/recovery orchestration; ARM64 device matrix; CI/signing infrastructure; version numbering.

Resolve each via design review/ADR before the relevant implementation phase.

## Governance

Written proposal → impact/security review → ADR where material → explicit approval → documentation update → **separate implementation authorization**. See [ROADMAP](../../ROADMAP.md) and [AGENTS](../../AGENTS.md).
