# ADR-0008 — Desktop Edition Architecture

**Project:** DesKaOne OS  
**Document version:** Final R1  
**Status:** Accepted — architecture/documentation only  
**Decision date:** 2026-10-24  
**Scope:** Desktop Edition, Shared Core, Installation, Packaging and Recovery  
**Initial architecture:** AMD64  
**Project phase:** Phase 0 — Architecture & Documentation  
**Implementation authorization:** Not granted

## 1. Context

DesKaOne OS Desktop Edition is a Debian 13 (Trixie)-based KDE Plasma desktop distribution. It needs a maintainable session/login stack, minimal default application selection, controlled optional app distribution, upstream-compatible drivers, accessible user experience and tested recovery paths.

The Desktop Edition must follow ADR-0001 through ADR-0006 and remain compatible with the approved KDE Plasma Live ISO + Calamares installation path from ADR-0002, Btrfs storage policy from ADR-0003 and Debian-native build strategy from ADR-0004.

## 2. Decisions

### D1 — KDE Plasma and Wayland-first session

- **KDE Plasma** is the primary desktop environment.
- **Wayland** is the preferred/default session **only on validated hardware and package combinations**.
- Provide an **X11 fallback where the relevant Debian/KDE session packages are available and tested**. Do not promise X11 fallback universally or silently substitute unsupported packages.
- Verify compositor behavior, display scaling, multiple monitors, screen capture/sharing, input methods, accessibility and GPU-specific behavior.
- Session selection and fallback should be visible and recoverable at login.
- Keep Debian-packaged KDE components wherever practical; avoid unnecessary KDE forks.

### D2 — SDDM display manager

- Adopt **SDDM** as the planned graphical login manager, subject to compatibility testing with the selected Debian/KDE packages and sessions.
- Support non-root user login, session selection, secure authentication and clear failure/recovery paths.
- Do not enable automatic login by default.
- Avoid embedding credentials in live media or installed systems.
- Validate accessibility, localization, multi-user switching and login recovery.

### D3 — Minimal essential applications

- Ship a **minimal essential** desktop application set, with optional bundles for productivity, development, multimedia and other use cases.
- Select baseline apps based on maintainability, licensing, Debian availability, accessibility and resource use.
- Define a consistent core experience: file management, terminal, browser strategy, settings, networking, updates, help and basic utilities. Exact package choices remain open.
- Avoid preinstalling large or redundant application suites without a documented user need.
- Make optional bundles explicit and removable without breaking the shared core.
- Do not claim package availability or specific default apps until manifests are approved and tested.

### D4 — APT primary, Flatpak optional

- **APT/dpkg** remains the primary mechanism for OS, KDE, system services and DesKaOne packages, consistent with ADR-0005.
- **Flatpak** is an optional channel for suitable user applications, not a replacement for core OS package management.
- Do not automatically trust or enable third-party Flatpak remotes without explicit policy and user/admin consent.
- Clearly distinguish APT and Flatpak app sources, permissions and update behavior.
- Evaluate sandbox permissions, portals, filesystem/device access, application updates and removal.
- Avoid duplicate app installations and inconsistent update UX where practical.
- Flatpak availability is not a claim of complete isolation or application safety.

### D5 — Debian kernel, firmware and optional proprietary drivers

- Use the **official Debian kernel and compatible Debian firmware** as the default hardware foundation; no custom DesKaOne kernel or driver stack initially.
- Non-free firmware and proprietary drivers must be **optional, transparent and license-compliant**.
- Explain any installation-time requirements for Wi-Fi/GPU firmware and the implications of third-party drivers.
- Validate AMD64 hardware including Intel/AMD/NVIDIA graphics where supported, Wi-Fi, Ethernet, Bluetooth, audio, touchpads, suspend/resume, power management, displays and removable media.
- Preserve compatibility with Debian security updates, DKMS/module handling and phased Secure Boot requirements; proprietary module signing must be evaluated before support claims.
- Hardware support is conditional on verified driver and firmware availability.

### D6 — Btrfs snapshots, independent backups and rescue

- Follow ADR-0003: **Btrfs** is the Desktop root filesystem default.
- Design optional/appropriate **Btrfs snapshots** for system recovery, with documented subvolume layout, retention and cleanup.
- **Snapshots are not backups**; support independent backup and restore of user data and important configuration.
- Provide rescue paths for broken updates, boot failure, damaged login sessions and storage problems.
- Snapshot rollback must account for changes to package state, bootloader, kernel, external partitions and application/user data.
- Do not promise automatic bootable snapshot rollback until boot integration and restore behavior are tested.
- Optional LUKS2 encryption and swap must remain compatible with Btrfs and recovery design.

### D7 — Installation, onboarding and branding

- Retain the **KDE Plasma Live ISO + Calamares** approach from ADR-0002; test both live and installed environments.
- Onboarding should clearly explain account creation, optional firmware/drivers, encryption, updates and backup/recovery choices.
- Branding may customize wallpapers, themes, defaults and help materials without unnecessarily patching KDE internals.
- Preserve upstream licenses and attribution; allow users to revert to standard KDE appearance.
- Plan accessibility and localization from initial design rather than as afterthoughts.

### D8 — Security and updates

- Apply ADR-0006 non-root accounts, sudo/polkit, validated AppArmor, edition-specific nftables and security-event logging.
- No SSH server or public remote-management service enabled by default.
- Follow ADR-0005: Debian official + DesKaOne overlay, Stable/Testing/Unstable channels, protected APT selection, safeguarded security updates and manual major upgrades.
- Update UX should show pending changes, errors and restart requirements without uncontrolled automatic reboots.
- Flatpak app update behavior, when enabled, must be separately visible and controllable.

### D9 — Performance and hardware support

- Set minimum and recommended RAM/storage/graphics requirements only after representative hardware testing.
- Prioritize usable boot/login times, responsive Plasma sessions and predictable idle resource consumption.
- Avoid excessive background services and redundant package managers.
- Document tested GPU/session combinations and known limitations.

### D10 — Prior ADR compatibility

Preserve Debian 13 Trixie, AMD64-first strategy, official kernel, Debian Installer/Calamares decisions, GRUB 2 and phased Secure Boot, Btrfs/optional LUKS2, Debian-native image pipeline, signed release artifacts, overlay APT channels, and shared security controls. Incompatible changes require a separate architecture review.

## 3. Alternatives considered

| Area | Selected | Alternative not selected |
| --- | --- | --- |
| Session | Wayland-first, validated X11 fallback | X11-first |
| Display manager | SDDM | GDM |
| Apps | Minimal essentials + optional bundles | Full suite preinstalled |
| Distribution | APT primary + optional Flatpak | APT only |
| Hardware | Debian kernel/firmware, optional proprietary | Custom kernel/driver stack |
| Recovery | Btrfs snapshots + independent backups + rescue | Backups and rescue without snapshots |

## 4. Consequences

**Benefits:** Upstream-compatible KDE desktop; Wayland-first experience where verified; lean default apps; optional app ecosystem; reduced kernel/driver maintenance; layered recovery; consistent Debian security and package policy.

**Risks:** Hardware-specific Wayland failures; X11 package availability differences; SDDM session compatibility; Flatpak remote/sandbox trust; proprietary driver and Secure Boot complexity; snapshot space use and false assumptions about rollback; incomplete accessibility/hardware coverage.

## 5. Future verification requirements

These are **future acceptance criteria, not completed tests**:

1. KDE Plasma Live ISO boot and Calamares installation.
2. SDDM login, session selection and recovery.
3. Wayland on validated Intel/AMD/NVIDIA hardware.
4. X11 fallback availability and functionality where advertised.
5. Multi-monitor, scaling and display hotplug.
6. Screen capture/sharing, portals and input methods.
7. Keyboard, accessibility and localization workflows.
8. Minimal app selection and optional bundle installation/removal.
9. APT package origin, update and dependency correctness.
10. Flatpak remote trust, permissions and update visibility when enabled.
11. Wi-Fi/Ethernet/Bluetooth/audio support on tested hardware.
12. Suspend/resume and power management.
13. Optional proprietary drivers and Secure Boot compatibility where claimed.
14. Non-root sudo/polkit and AppArmor compatibility.
15. No default SSH/public management exposure.
16. Btrfs subvolume and snapshot lifecycle.
17. Independent backup and restore.
18. Recovery from broken login/update/boot.
19. Optional LUKS2 and Btrfs-compatible swap.
20. Debian 13 and prior-ADR compatibility.

## 6. Open decisions

- Exact KDE Plasma/SDDM packages and supported session combinations on Debian 13.
- Essential app list and optional bundle manifests.
- Browser strategy and default application choices.
- Flatpak remote policy, user consent and sandbox permissions.
- Desktop update frontend and UX.
- Branding assets, accessibility and localization targets.
- Hardware compatibility matrix and minimum specifications.
- Proprietary driver enrollment and module signing procedures.
- Btrfs subvolume/snapshot tooling, retention and boot recovery integration.
- Backup/restore tooling and user-data policy.

## 7. Phase restrictions

**Phase 0 — Architecture & Documentation Only.** This ADR does **not** authorize KDE configuration, package manifests/builds, themes/assets, Flatpak remotes, drivers, snapshots, installers, ISO generation, CI/CD, host changes or Phase 1 implementation. All implementation requires separate explicit approval.

## 8. Approval record

On **2026-10-24**, the project owner selected Wayland-first with validated X11 fallback, SDDM, minimal apps plus optional bundles, APT primary with optional Flatpak, Debian kernel/firmware with optional proprietary drivers, and Btrfs snapshots plus independent backup and rescue. **Final Draft R1 was subsequently approved for documentation publication.**
