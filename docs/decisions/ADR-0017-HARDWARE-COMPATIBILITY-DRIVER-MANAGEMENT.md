# ADR-0017 — Hardware Compatibility & Driver Management Architecture

**Project:** DesKaOne OS  
**Version:** Final R1  
**Status:** Accepted — architecture/documentation only  
**Decision date:** 2026-10-25  
**Scope:** Hardware support, detection, drivers, firmware, compatibility validation, and diagnostics across Server, Network, and Desktop editions  
**Implementation authorization:** Not granted

## 1. Context and objectives

DesKaOne OS is a Debian Stable-based distribution with Server, Network, and Desktop editions. Hardware compatibility must be grounded in verified platforms and Debian-supported driver/firmware packages rather than assuming all devices work. The initial platform target is AMD64, with ARM64 added through staged validation. Network and storage devices are particularly critical for remote servers and gateways; desktop graphics and Wayland behavior require separate compatibility evaluation.

This ADR defines architecture-level policies for hardware discovery, classification, driver/firmware selection, update compatibility, and privacy-safe diagnostics. It inherits ADR-0001 through ADR-0016 without reopening accepted decisions.

## 2. Approved decisions

### H01 — AMD64-first with phased ARM64 support

- Treat AMD64 as the initial supported architecture target.
- Introduce ARM64 only after explicit validation of relevant hardware families, boot chain, firmware, kernel support, installation, and edition-specific requirements.
- Do not equate kernel architecture support with validated board, SoC, firmware, bootloader, or device support.
- Record platform-specific limitations and exclude unvalidated hardware from supported claims.
- Exact supported CPU generations, boards, firmware versions, and certification thresholds are deferred to technical design.

### H02 — Debian kernel and packaged driver foundation

- Prefer the Debian Stable kernel, in-tree kernel modules, Debian-packaged drivers, and maintained Debian package-management mechanisms.
- Install, update, and remove driver packages through authenticated APT/dpkg repositories consistent with the approved security and update architecture.
- Avoid a separately maintained custom driver stack as the default.
- Treat out-of-tree modules, DKMS dependencies, Secure Boot module signing, and kernel ABI changes as explicit compatibility risks requiring validation.
- Do not silently replace the kernel or introduce unsupported repositories to enable a device.
- Exact driver package lists and supported kernel variants remain deferred.

### H03 — Controlled Debian firmware components

- Obtain firmware through approved Debian repository components and other explicitly trusted, legally distributable sources where required.
- Preserve provenance, applicable licensing information, package version, and source/repository identity for firmware.
- Distinguish free/open drivers from proprietary or redistributable firmware blobs; do not conflate them.
- Include firmware only when justified by supported hardware and edition artifact profiles; avoid indiscriminate bundling.
- Inform administrators when functionality depends on non-free firmware and provide opt-in/approval controls where policy requires.
- Firmware availability does not imply that every hardware model using that firmware has been validated.

### H04 — Read-only discovery and compatibility classification

- Detect hardware using established Linux/Debian mechanisms without silently modifying routing, interface names, boot configuration, or other critical settings.
- Inventory relevant CPU/architecture, PCI/USB devices, storage controllers, network adapters, graphics devices, and firmware/boot characteristics as needed.
- Classify hardware using evidence-backed states: **Supported**, **Limited**, **Unsupported**, or **Unknown**.
- Reserve **Supported** for a documented, tested combination of device/platform, driver, firmware, kernel, architecture, and edition where applicable.
- Use **Limited** for verified partial functionality, **Unsupported** for known failures or explicitly excluded combinations, and **Unknown** for insufficient evidence.
- Distinguish hardware detection from authorization to install a driver or change system configuration.

### H05 — Open graphics drivers first; proprietary optional

- Prefer open graphics drivers available through Debian where compatible with the approved desktop baseline.
- Make proprietary GPU drivers optional and subject to explicit administrator choice, license/source disclosure, supported hardware/kernel compatibility, and recovery guidance.
- Validate Desktop graphics against KDE Plasma, Wayland-first sessions, and SDDM, including known limitations and safe alternative login/session options where supported.
- Avoid enabling proprietary graphics drivers by default on all systems or promising identical behavior across GPU generations.
- Server and Network editions should not acquire unnecessary desktop graphics dependencies.

### H06 — Edition-aware critical network and storage validation

- **Server:** prioritize storage controllers, boot firmware, network adapters, virtualization/platform compatibility, and reliable remote management.
- **Network:** prioritize wired/wireless interfaces, multi-NIC mapping, firmware, routing/firewall continuity, and recovery from management lockout.
- **Desktop:** prioritize GPU/display, audio, wireless/Bluetooth, input, storage, and session readiness.
- Check boot-critical and connectivity-critical hardware compatibility before installation or disruptive driver changes where feasible.
- Do not automatically reassign network interfaces, replace routes, or change firewall policies solely because new hardware is detected.
- Require documented fallback or recovery paths for critical driver failures; acknowledge that some physical failures cannot be reversed remotely.

### H07 — Kernel, driver, and firmware compatibility gates

- Apply kernel/driver/firmware updates through authenticated packages and the approved update policy.
- Evaluate known kernel-module ABI constraints, DKMS rebuild requirements, Secure Boot restrictions, firmware dependencies, and device-specific regressions before critical changes.
- Require appropriate preflight and post-update checks for boot, storage, networking, and display/session readiness.
- Provide repair/recovery guidance such as known-good boot options, package repair, driver reversal where supported, and backups; do not promise universal atomic rollback.
- Do not automatically install the newest available third-party driver regardless of compatibility.
- Define exact supported driver/kernel matrices and gate thresholds during technical design.

### H08 — Versioned compatibility matrix and privacy-safe diagnostics

- Maintain a versioned compatibility matrix keyed by hardware/platform identity and the tested OS release, kernel, driver, firmware, architecture, and edition.
- Record evidence, test date, known limitations, and recovery notes; distinguish laboratory validation from community reports.
- Keep hardware diagnostics local by default and provide readable reports with actionable failure context.
- Do not automatically transmit MAC addresses, device serial numbers, unique machine identifiers, or other sensitive inventory to DesKaOne-operated services.
- If optional diagnostic sharing is introduced later, require explicit informed opt-in, data minimization, redaction, and retention controls.
- Do not mark unknown hardware as supported merely because a generic driver is present.

## 3. Conceptual hardware lifecycle

1. **Discover:** collect relevant local device, bus, firmware, boot, and platform information without changing system configuration.
2. **Classify:** compare against versioned evidence and identify Supported, Limited, Unsupported, or Unknown states.
3. **Plan:** select edition-appropriate Debian driver/firmware packages and disclose licensing or optional proprietary dependencies.
4. **Validate critical paths:** confirm storage/boot and management network prerequisites, and desktop display requirements where applicable.
5. **Apply approved changes:** install or update packages through authenticated APT/dpkg workflows with administrator control.
6. **Check readiness:** evaluate boot, connectivity, storage, display/session, and driver health appropriate to the edition.
7. **Diagnose and recover:** provide local, privacy-safe logs and documented repair/fallback steps.
8. **Record compatibility evidence:** update the versioned matrix only after appropriate testing and approval.

This is an architectural lifecycle, not an implemented hardware management daemon.

## 4. Edition-specific compatibility priorities

| Edition | Priority hardware | Important validation |
| --- | --- | --- |
| Server | CPU/virtualization, storage controller, boot firmware, NIC | Headless boot, persistent storage, remote access and recovery |
| Network | Multi-NIC, Ethernet, Wi-Fi where applicable, boot/storage, firmware | Stable interface mapping, routing/firewall operation, management reachability |
| Desktop | GPU, display, Wi-Fi/Bluetooth, audio, input, storage | KDE Plasma Wayland/SDDM session, driver behavior, user-facing recovery |

AMD64 is the initial validation target. ARM64 requires platform-by-platform evidence before publication of supported artifacts.

## 5. Alternatives considered

| Decision | Selected | Rejected as default |
| --- | --- | --- |
| H01 | AMD64-first; phased ARM64 | Immediate broad architecture support without validation |
| H02 | Debian kernel and packaged drivers | Custom driver stack |
| H03 | Controlled Debian firmware components | Indiscriminate firmware bundling |
| H04 | Read-only detection and evidence-backed classification | Silent automatic hardware reconfiguration |
| H05 | Open graphics drivers first; proprietary optional | Default proprietary graphics installation |
| H06 | Edition-aware critical hardware checks | Generic discovery without critical validation |
| H07 | Kernel/firmware compatibility gates | Always install newest drivers |
| H08 | Versioned compatibility matrix and privacy-safe diagnostics | No formal compatibility tracking |

## 6. Consequences, risks, and mitigations

**Benefits:** Debian-aligned maintenance, clear supported-hardware boundaries, lower driver maintenance cost, transparent firmware sourcing, safer gateway/server upgrades, better Desktop graphics support decisions, and user privacy.

**Risks:** Missing proprietary firmware, unsupported or untested hardware, kernel/driver regressions, DKMS failures, Secure Boot incompatibilities, GPU/Wayland session failures, storage or NIC loss after updates, and sensitive device identifiers in logs.

**Mitigations:** Staged architecture/platform support, signed packages, versioned compatibility evidence, explicit proprietary-component choices, edition-specific preflight and health checks, documented recovery paths, and local-first/redacted diagnostics.

Compatibility classifications are evidence-specific and may change with OS, kernel, firmware, or driver versions. A driver loading successfully is not sufficient proof of complete hardware support.

## 7. Future acceptance criteria — not executed

1. Verify AMD64 boot/install and representative edition hardware paths before supported release claims.
2. Define ARM64 board/platform-specific test coverage before publishing ARM64 support.
3. Confirm driver/kernel/firmware packages originate from approved authenticated repositories.
4. Validate firmware provenance, license notices, and selective inclusion in edition images.
5. Confirm hardware detection is read-only and cannot silently rewrite routing, storage, or boot settings.
6. Test Supported/Limited/Unsupported/Unknown classification using documented evidence and unknown-device cases.
7. Verify open-driver-first Desktop behavior and optional proprietary-driver consent and compatibility gates.
8. Test KDE Plasma Wayland/SDDM readiness and fallback diagnostics on representative GPU combinations.
9. Exercise Server and Network boot, storage, NIC, multi-interface, and remote-management recovery checks.
10. Test kernel, DKMS, firmware, and Secure Boot compatibility scenarios and failure reporting.
11. Validate versioned compatibility matrix metadata and distinguish tested results from unverified reports.
12. Confirm diagnostics do not automatically upload hardware serials, MAC addresses, or unique device identities.

These are future validation requirements; no driver, firmware, detector, compatibility service, image, or runtime test has been implemented or executed.

## 8. Deferred technical design

Exact supported hardware models; PCI/USB identification schema; discovery tools; driver and firmware package inventories; Debian repository component policy; kernel and firmware version matrices; DKMS and Secure Boot procedures; GPU fallback details; compatibility evidence schema; diagnostic report format; opt-in sharing design; release certification criteria; and hardware-specific recovery runbooks are deferred to separately approved technical design and implementation.

## 9. Approval and scope

The project owner approved H01=A, H02=A, H03=A, H04=A, H05=A, H06=A, H07=A, and H08=A, then separately approved publication of ADR-0017 Final R1 through feature branch, commit, pull request, squash merge, and verification on `main`.

This ADR inherits ADR-0001 through ADR-0016 without reopening accepted decisions.

**Phase 0 — Architecture & Documentation Only.** No source code, driver installation, firmware modification, hardware probing on hosts, installer/ISO/cloud-image builds, deployment, runtime tests, or GitHub Actions execution is authorized.
