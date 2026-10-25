# ADR-0009 — Server Edition Architecture

**Project:** DesKaOne OS  
**Version:** Final R1  
**Status:** Accepted — architecture/documentation only  
**Decision date:** 2026-10-25  
**Scope:** Server Edition and Shared Core  
**Initial architecture:** AMD64  
**Implementation authorization:** Not granted

## 1. Context

DesKaOne OS Server Edition targets small VPS instances, cloud virtual machines, homelabs, and bare-metal servers on Debian 13 (Trixie). It must remain lightweight, secure, recoverable, upstream-compatible, and extensible without imposing application-specific services. This ADR specializes ADR-0001 through ADR-0006 and preserves separation from the Network and Desktop editions defined by ADR-0007 and ADR-0008.

## 2. Approved decisions

### S01 — Minimal headless baseline

- Provide a headless system without graphical desktop, display manager, or GUI dependencies.
- Use the official Debian kernel, systemd, APT/dpkg, and a small set of essential system and administration utilities.
- Do not install or enable a web server, database, container engine, public dashboard, router, or gateway service by default.
- Use independently installable, removable edition-specific metapackages and optional service bundles without breaking the shared core.
- Minimize default network listeners and background processes. Exact package manifests are deferred to technical design and validation.

### S02 — Networking and remote administration

- Use **systemd-networkd** for the initial server interface-management foundation, with explicit ownership and no conflicting network manager.
- Use **OpenSSH**, with public-key authentication preferred, disabled direct root SSH login, and constrained administrative access.
- SSH enablement and firewall allowance must be explicitly coordinated during installation or provisioning; an unreachable or unprotected remote host is not an acceptable default.
- Use **nftables** for host firewall policy, denying unsolicited inbound connections except administrator-authorized services. Document IPv4 and IPv6 behavior.
- Protect remote changes with preflight validation, out-of-band console or rescue options, and rollback/recovery procedures; do not assume atomic network reconfiguration.
- Do not enable IP forwarding, NAT, DHCP server, DNS forwarding, VPN gateway, or Network Edition management services by default.

### S03 — Installation and cloud provisioning

- Use Debian Installer for interactive/text-mode and planned unattended server installation, consistent with ADR-0002.
- Plan separately validated cloud images using **cloud-init**, with provider-specific metadata and image formats defined later.
- Provision hostnames, administrative identities, SSH authorized keys, and initial network configuration without shared default passwords.
- Ensure unique machine identity and SSH host keys on each deployed instance; reusable images must not contain machine-specific identities or secrets.
- Require explicit authorization for destructive unattended disk operations.
- Retain Debian GRUB 2, UEFI/Legacy BIOS design, and conditional, fully validated Secure Boot claims.

### S04 — Optional container runtimes

- Do not include a container runtime in the default Server baseline.
- Support optional **Docker** and **Podman** modules; Docker Compose is an optional companion where available and validated.
- Define Debian/DesKaOne package origin and trust policy before selecting installation sources. Never silently enable third-party repositories.
- Document daemon privileges, rootless options, socket exposure, networking/firewall interactions, cgroup/systemd compatibility, storage usage, logging, updates, and rollback.
- Do not promise simultaneous runtime interoperability or universal workload compatibility without tests.

### S05 — Updates, maintenance and lifecycle

- Follow ADR-0001 and ADR-0005: automatically apply eligible security updates by default, subject to validated safeguards and administrator visibility.
- Use controlled maintenance for routine non-security updates; require explicit approval and tests for major Debian release upgrades.
- Do not perform uncontrolled automatic reboots. Surface reboot-required state and update failures.
- Plan recovery for interrupted APT/dpkg transactions, broken packages, kernel/GRUB changes, and remote-access failures.
- Keep official Debian repositories distinct from the signed DesKaOne overlay, with scoped signing-key trust and protected package selection.

### S06 — Logging and observability

- Use systemd-journald as the baseline logging mechanism, with bounded retention, storage limits, and rotation/cleanup policy.
- Provide essential service, boot, authentication, storage, update, and security-event diagnostics while avoiding secret leakage.
- Offer metrics exporters, alerting integrations, and centralized log shipping only as opt-in modules.
- Avoid installing a full monitoring stack by default; plan health and disk-pressure visibility for small VPS instances.
- Set retention and metric cardinality limits only after representative testing.

### S07 — Resource profiles and performance

- Maintain one minimal shared Server core with optional VPS and bare-metal configuration profiles rather than distinct OS foundations for each machine size.
- Avoid mandatory high-memory services and unnecessary persistent writes.
- Evaluate idle RAM, boot time, storage footprint, CPU usage, update behavior, and performance under representative workloads.
- Do not publish minimum/recommended hardware requirements or capacity claims before measurements on validated AMD64 VPS and physical hosts.
- ARM64 support remains deferred to a separately approved phase.

### S08 — Security, storage and recovery

- Use **ext4** as the default root filesystem, with optional separate data filesystems and workload-dependent optional swap, per ADR-0003.
- Offer **optional LUKS2** where supported; explain remote unlock, unattended restart, key custody, and recovery tradeoffs before enabling it.
- Require non-root administration with sudo, least privilege, AppArmor policy validation, constrained SSH, nftables, and security-event auditability per ADR-0006.
- Require independent backups and tested restoration plans for system configuration, service data, and boot/recovery material. Filesystem snapshots are not a mandatory Server feature and are not a backup substitute.
- Design rescue paths for filesystem failure, broken bootloader, lost SSH/network access, failed updates, and inaccessible encrypted disks.
- Do not embed credentials, keys, or reusable identities in installation artifacts.

## 3. Alternatives considered

| Area | Selected | Not selected as initial default |
| --- | --- | --- |
| Server baseline | Minimal headless + modular services | Preinstalled general-purpose service stack |
| Networking | systemd-networkd, OpenSSH key-first, nftables | NetworkManager as default |
| Provisioning | Debian Installer + planned cloud-init images | Installer-only deployment |
| Containers | Optional Docker and Podman | Mandatory Docker or mandatory Podman |
| Updates | Safeguarded automatic security updates, controlled reboot | Entirely manual security updates |
| Monitoring | journald baseline, optional exporters | Mandatory full monitoring stack |
| Profiles | Shared minimal core, optional VPS/bare-metal profiles | Separate OS foundation per resource tier |
| Storage/security | ext4, optional LUKS2, AppArmor, independent backups | Mandatory snapshot-based storage |

## 4. Consequences and risks

**Benefits:** Low default resource overhead, smaller attack surface, Debian package compatibility, clear server/network edition boundaries, flexible workload modules, VPS/cloud readiness, and recoverable administration.

**Risks:** Cloud-provider network and metadata differences, SSH lockout during provisioning, package-source drift for container runtimes, nftables/container networking conflicts, automatic security-update regressions, delayed reboots, disk exhaustion from logs, remote LUKS unlock complexity, and backup/restore gaps. Each requires explicit technical design and validation.

## 5. Future verification criteria (not executed)

1. AMD64 headless installation and boot on supported UEFI/BIOS paths.
2. Minimal package and open-port inventory; no unintended GUI or server listeners.
3. networkd interface persistence, IPv4/IPv6 configuration, and no manager conflicts.
4. Secure SSH key provisioning, no direct root SSH login, and safe recovery from lockout.
5. nftables policy and authorized inbound service behavior.
6. Cloud-init provisioning, unique host keys/machine identity, and tested provider metadata.
7. Optional Docker and Podman installation/removal, package provenance, privilege and firewall compatibility.
8. Security-update installation, failure reporting, no uncontrolled reboot, and manual major-upgrade safeguards.
9. journald retention, disk-pressure behavior, audit visibility, and secret redaction.
10. Resource measurements on small VPS and representative bare-metal hardware.
11. ext4, optional swap/LUKS2, boot/recovery behavior, and verified independent backup restore.
12. AppArmor and non-root sudo policy, signed package/repository integrity, and ADR compatibility.

## 6. Deferred technical design

Exact package manifests and metapackage dependencies; default network configuration and DNS resolver integration; SSH bootstrap and emergency access; cloud image formats and provider support; container repository/version policy; firewall integration with container networking; security update scheduling and reboot notifications; log retention/exporter selections; VPS and bare-metal tuning; LUKS2 remote unlock; backup tooling, retention, restore verification, and detailed rescue procedures. These are not implied to be implemented.

## 7. Compatibility and scope restrictions

- **ADR-0001:** Debian 13 Trixie, AMD64-first, official kernel, APT/dpkg/systemd, safeguarded updates.
- **ADR-0002:** Debian Installer, planned cloud-init, GRUB 2, phased Secure Boot.
- **ADR-0003:** Server ext4, optional swap and LUKS2, independent backups and rescue.
- **ADR-0004:** Debian-native future build process and signed release manifests; no builds authorized.
- **ADR-0005:** Official Debian plus signed DesKaOne overlay, controlled package channels.
- **ADR-0006:** Non-root sudo, AppArmor, nftables, constrained SSH, auditing and recovery.
- **ADR-0007:** Shared network technologies are compatible; Server is not a default router or gateway.
- **ADR-0008:** KDE/Wayland/SDDM and Desktop Btrfs defaults do not apply to headless Server.

**Phase 0 — Architecture & Documentation Only.** This ADR authorizes no code, host configuration, installation, package build, ISO/cloud image build, CI/CD workflow, service deployment, or advancement to Phase 1. GitHub Actions remain disabled.

## 8. Approval record

On 2026-10-25, the project owner approved S01=A, S02=A, S03=A, S04=A, S05=A, S06=A, S07=A, S08=A, then explicitly approved publication of ADR-0009 Final R1 through feature branch, commit, pull request, squash merge, and verification on main. Approval is limited to documentation.
