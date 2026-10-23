# DesKaOne OS Roadmap

**Architecture:** v0.1 · **Status:** documentation-only checkpoint · **Release dates:** not committed

## Status vocabulary

Planned = not authorized; Approved = explicitly authorized for stated scope; In Progress = authorized work started; Blocked = awaiting decision; Completed = acceptance evidence reviewed.

| Phase | Focus | Status | Exit criteria |
| --- | --- | --- | --- |
| 0 | Architecture & documentation | Approved for documentation only | Architecture, roadmap, agent policy and design risks reviewed |
| 1 | Core & AMD64 build | Planned | Clean reproducible image, boot tests, manifest, package integrity |
| 2 | Server MVP | Planned | Headless install, SSH/firewall, network persistence, updates and recovery tested |
| 3 | Network MVP | Planned | Routing/NAT, VPN, authenticated web + CLI, safe config rollback tested |
| 4 | KDE Desktop MVP | Planned | Graphical install/login, network/audio, updates and hardware matrix tested |
| 5 | Release infrastructure | Planned | Signed APT repository, artifacts, provenance, security/upgrade gates |
| 6 | ARM64 enablement | Planned | ARM64 build/boot and documented supported devices tested |

## Phase 0 — documentation

Deliverables: `docs/architecture/ARCHITECTURE.md`, edition specifications, `ROADMAP.md`, `AGENTS.md`, security/update policy, package/build design and ADRs. Review unresolved design choices before implementation.

## Phase 1 — shared core

Proposed: Debian Stable baseline, `deskaone-core` and `deskaone-release` package design, isolated AMD64 build pipeline, image manifests and boot/package tests. **Requires separate explicit approval.**

## Phase 2 — Server

Proposed: headless installer, SSH, systemd-networkd, nftables, service lifecycle, recovery documentation, resource benchmark. **Requires separate explicit approval.**

## Phase 3 — Network

Proposed: router/gateway, nftables, WireGuard, DNS/DHCP, Go/HTMX dashboard and CLI sharing validated management operations; remote-change confirm/rollback; audit, isolation and throughput tests. **Requires separate explicit approval.**

## Phase 4 — Desktop

Proposed: KDE Plasma, SDDM, Wayland, PipeWire, NetworkManager, GUI package management, developer profile and hardware compatibility tests. **Requires separate explicit approval.**

## Phase 5 — release hardening

Proposed: repository and artifact signing, protected keys, release manifest, provenance, staging, tested upgrade/recovery path and advisories. Production distribution is gated on these controls. **Requires separate explicit approval.**

## Phase 6 — ARM64

Proposed: ARM64 package/image pipeline, generic ARM64 UEFI tests, firmware and device-specific boot support, documented compatibility matrix. **Requires separate explicit approval.**

## Cross-phase requirements

Every phase requires scope approval, Debian compatibility review, security review, automated evidence, documentation updates and explicit acceptance. Core changes need impact analysis across all three editions. Successful build does not mean release-ready.

## Risks

- Upstream incompatibility: minimize forks and test upgrades.
- Unsafe router changes: transactional apply, confirm and rollback.
- Privileged dashboard compromise: non-root service, narrowly scoped executor.
- Key compromise: signing isolation and documented rotation.
- Hardware fragmentation: publish only tested device support.
- Scope creep: explicit phase gates.

**Checkpoint:** architecture v0.1 approved for documentation; implementation remains unauthorized.
