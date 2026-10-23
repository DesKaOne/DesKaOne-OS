# ADR-0001 — Debian Baseline and Upstream Compatibility

**Project:** DesKaOne OS  
**Version:** Final R1  
**Status:** Accepted for architecture/documentation only  
**Decision date:** 2026-10-24  
**Applies to:** Shared Core, Server, Network, Desktop  
**Implementation authorization:** Not granted

## Context

DesKaOne OS is a Debian-derived, community-oriented Linux distribution with three editions: Server (headless VPS, bare metal and homelabs), Network (router, gateway, firewall and VPN), and Desktop (KDE Plasma). They require a shared maintainable base compatible with Debian's package and security ecosystem.

## Decisions

### D1 — Debian baseline

- Adopt **Debian 13 (Trixie)** for all initial editions.
- Support **AMD64** first; defer ARM64 to a separately approved phase.
- Use the fixed Debian codename `trixie` in repository configuration, not the moving alias `stable`.
- Require an explicit architecture decision and migration tests before upgrading to a future Debian major release.

### D2 — Upstream package compatibility

- Retain **APT**, **dpkg**, and **systemd**.
- Prefer official Debian packages and their upstream security maintenance.
- Keep DesKaOne-specific packages separate, preferably named `deskaone-*`.
- Do not silently replace essential Debian packages. Any divergence requires an approved decision, documented maintenance ownership, and compatibility tests.

### D3 — Updates

- **Automatically install security updates by default**, subject to edition-specific safeguards and validation.
- Manage routine non-security updates through a controlled maintenance policy.
- Keep major Debian release upgrades **manual**, approved, and tested.
- Never perform uncontrolled automatic reboots.
- Expose update status, failures, and pending reboot requirements.
- Network Edition must protect connectivity and remote administrative recovery.
- Detailed update tooling, maintenance windows, rollback and failure handling are deferred to subsequent designs.

### D4 — Firmware

- **Non-free firmware is optional**, based on hardware requirements and applicable licenses.
- Debian's `non-free-firmware` component may be made available where justified.
- Clearly distinguish proprietary firmware and licensing; do not require unrelated proprietary firmware.
- Installer-time firmware selection and consent are deferred to installer design.

### D5 — Kernel

- Use **official Debian Linux kernel packages** initially.
- Do not maintain a custom kernel fork for the initial release.
- Review additional kernel modules for security and compatibility.
- Consider a custom kernel only with a separate evidence-backed ADR and approval.

### D6 — Repository trust

- Separate official Debian repositories from DesKaOne-controlled repositories.
- Authenticate repository metadata and packages cryptographically.
- Scope APT signing-key trust to its repository, avoiding unnecessary global trust.
- Keep signing credentials separate from runtime credentials.
- Design signing-key rotation, repository availability, and compromise recovery before production release.
- This ADR does not authorize repository infrastructure deployment.

## Alternatives considered

| Alternative | Assessment |
| --- | --- |
| Debian 13 Trixie | Selected |
| Debian Testing | Not selected due to higher change rate |
| Debian Unstable | Not selected as a production foundation |
| Ubuntu LTS | Not selected; direct Debian compatibility prioritized |
| From-scratch distribution | Not selected due to maintenance and security burden |
| Custom kernel by default | Not selected without technical justification |

## Consequences

**Benefits:** Shared foundation across editions, Debian package compatibility, upstream security maintenance, reduced maintenance burden, and familiar workflows for contributors.

**Risks:** Older upstream package versions, occasional update regressions, hardware-dependent proprietary firmware, major-upgrade testing, and DesKaOne repository signing/operational responsibilities.

## Edition-specific requirements

- **Server:** Predictable headless operation, maintenance windows, no uncontrolled reboots, Debian server package compatibility.
- **Network:** Maintain network availability and administrator access; validate recovery and connectivity around updates affecting critical services.
- **Desktop:** Start with Debian-supported KDE Plasma, provide transparent firmware choices and update/reboot notifications, consider accessibility and localization.

## Future verification criteria

The following are future acceptance criteria, **not completed tests**:

1. AMD64 installation and dependency resolution.
2. Correct Trixie repository and security-channel selection.
3. Security-update success and failure handling.
4. No unintended Debian major release upgrade.
5. No uncontrolled reboot.
6. Debian/DesKaOne package compatibility.
7. Firmware behavior and licensing disclosure.
8. Repository signature checks, key rotation and compromise recovery.
9. Recovery from interrupted package operations.
10. Edition-specific connectivity and administrator-access tests.

## Open decisions

Installer workflow; UEFI/legacy BIOS, bootloader and Secure Boot; filesystem, partitioning and encryption; ISO build and reproducibility; detailed update orchestration; repository hosting and signing; firmware-selection interface; and Debian major-version migration procedure.

Each substantial choice requires its own ADR or approved technical design.

## Scope and approval

The project owner approved the following architecture selections on **2026-10-24**: Debian 13 Trixie; automatic security updates with manual major upgrades; optional hardware-dependent firmware; and official Debian kernel packages.

**Approval is for documentation and architecture only.** No authorization is granted for OS implementation, package modifications, ISO builds, CI/CD, signing infrastructure deployment, host changes, or advancing the roadmap phase. Each requires separate explicit approval.
