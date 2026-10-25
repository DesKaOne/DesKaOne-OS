# ADR-0016 — Update, Upgrade & Rollback Architecture

**Project:** DesKaOne OS  
**Version:** Final R1  
**Status:** Accepted — architecture/documentation only  
**Decision date:** 2026-10-25  
**Scope:** Security updates, package updates, major release upgrades, configuration preservation, post-update validation, and recovery for Server, Network, and Desktop editions  
**Implementation authorization:** Not granted

## 1. Context and objectives

DesKaOne OS uses Debian Stable, Debian-native APT/dpkg packaging, signed repositories, and three modular editions. Updates must maintain security without unexpectedly disrupting servers, gateways, or desktop users. The architecture must respect administrator-owned configuration and recognize that APT/dpkg upgrades, filesystem snapshots, and application data migrations do not provide universal atomic rollback.

This ADR defines the update and recovery policy. It inherits ADR-0001 through ADR-0015 without reopening accepted decisions.

Objectives:
- Prefer Debian-native update mechanisms and authenticated package sources.
- Prioritize security fixes with edition-aware operational controls.
- Make automation configurable and conservative.
- Validate risk and recoverability before applying changes.
- Preserve local administrator changes.
- Provide realistic repair, restore, and rollback paths.
- Require explicit supported major-release migrations.
- Evaluate actual system health after updates.

## 2. Approved decisions

### U01 — Debian-native APT/dpkg update foundation

- Use Debian APT/dpkg for package discovery, dependency resolution, installation, upgrades, and package-state management; do not build a replacement package manager.
- Consume authenticated Debian and DesKaOne package repositories using the approved signing and repository trust architecture.
- Respect package ownership, held packages, dependency conflicts, and administrator overrides.
- Distinguish routine package updates from major OS release transitions and image publication.
- Keep the update orchestration layer thin and compatible with Debian package-manager locking, conffile handling, and failure semantics.
- Exact scheduling tools, interfaces, and commands are deferred to technical design.

### U02 — Security-first, edition-aware update policy

- Prioritize security updates and communicate severity, affected packages, service restart requirements, and reboot requirements where detectable.
- Apply policies appropriate to each edition rather than assuming identical downtime tolerances.
- **Server:** prioritize maintenance windows, service availability, and remote recovery.
- **Network:** prioritize routing/firewall continuity and management connectivity.
- **Desktop:** prioritize user notification, consent, and convenient reboot/recovery.
- Do not claim every security fix is safe to apply immediately without compatibility and operational checks.
- Provide a documented process for urgent security exceptions and deferred updates.

### U03 — Configurable, conservative automation

- Allow explicitly configured automatic updates or approved edition profiles; preserve administrator control over scope, timing, and restart behavior.
- Do not enable unattended major Debian/DesKaOne OS upgrades.
- Avoid unannounced disruptive reboots or automatic changes to critical network interfaces, firewall rules, or remote-access policy.
- Expose dry-run/preview capability where supported and report actions and failures.
- Support administrative opt-out, maintenance windows, and policy overrides consistent with the approved security baseline.
- Never interpret an automatic-update setting as permission for destructive storage operations or irreversible data migrations.

### U04 — Preflight dependency, disk, configuration, and connectivity checks

- Before applying significant updates, evaluate package dependency state, available storage, package-manager locks, incompatible repositories, and known configuration conflicts.
- Identify changes to kernel, bootloader, network stack, firewall, SSH, storage, and other critical services.
- For remotely administered Server and Network systems, assess recovery access and connectivity risk before disruptive operations.
- Check backup or restore readiness when the update may affect persistent state, while acknowledging that backup presence does not guarantee restorability.
- Stop or request explicit administrator intervention when safety preconditions cannot be met; avoid falsely claiming that all failures can be predicted.
- Define exact thresholds and risk classification in later technical design.

### U05 — Preserve administrator-owned configuration

- Follow Debian conffile semantics and approved configuration ownership boundaries.
- Do not silently overwrite administrator changes with edition defaults during package updates.
- Make configuration conflicts visible and provide an understandable resolution path; preserve backups or differences where appropriate.
- Distinguish package-owned defaults, generated configuration, administrator-managed files, and application data.
- Avoid reapplying first-boot or provisioning defaults over existing administrator customization.
- Document when package or schema migrations require manual intervention.

### U06 — Layered rollback and recovery, not universal atomic rollback

- Use appropriate recovery layers: package repair/reconfiguration, known-good kernel or boot entries where available, backups and restore procedures, manual rescue, and filesystem snapshots when supported.
- Desktop Btrfs snapshots may help restore compatible filesystem state, but snapshot creation, coverage, and bootability must be validated before relying on them.
- Server and Network ext4 defaults do not imply native filesystem snapshot rollback; rely on documented backup/restore, package repair, and platform-specific recovery mechanisms.
- Treat database migrations, application state, user data, secrets, and externally connected systems as separate consistency concerns.
- Do not promise a single-click, universally atomic rollback for APT/dpkg updates or major OS upgrades.
- Preserve the approved backup/disaster-recovery architecture and clearly communicate recovery limitations.

### U07 — Explicit supported major OS release migration

- Require an administrator-initiated, documented migration path for supported Debian/DesKaOne release transitions.
- Define supported source/target releases, edition compatibility, package repository changes, prerequisites, required backups, and expected service downtime before enabling a migration.
- Prevent silent cross-release repository switching or automatic major upgrades.
- Require validation of third-party packages, local configuration, storage/boot compatibility, and application/data migration constraints.
- Provide recovery guidance and explicit stop conditions if migration preflight fails.
- Do not assume every older release or unsupported upgrade path can be migrated in place.

### U08 — Post-update health checks, audit trail, and recovery guidance

- Verify package-manager outcome, pending configuration, reboot requirements, and relevant system/service readiness after applying updates.
- Check edition-relevant network connectivity and management access, particularly for Network and remote Server editions.
- Distinguish successful package installation from healthy services and usable system behavior.
- Record update metadata, applied package versions, status, errors, and recovery recommendations without exposing secrets.
- Report degraded states, partial success, and unresolved manual actions; do not silently mark them successful.
- Offer actionable recovery instructions and escalation paths for failed updates.

## 3. Conceptual update lifecycle

1. **Discover:** query authenticated Debian/DesKaOne repositories and classify security, routine, and major-release changes.
2. **Evaluate policy:** apply edition-specific scope, schedule, consent, and restart restrictions.
3. **Preflight:** assess dependencies, storage, configuration, network access, backup readiness, and potential disruption.
4. **Prepare recovery:** confirm feasible repair/restore options and document their limits.
5. **Apply:** use APT/dpkg under approved operational controls while preserving local configuration.
6. **Validate:** inspect package state, essential services, connectivity, security status, and reboot requirements.
7. **Complete or recover:** report healthy completion or degraded/failed state with repair, restore, or manual intervention guidance.
8. **Record:** retain a nonsecret audit trail and pending administrator actions.

This sequence is a design policy, not an implemented update engine or an atomic transaction.

## 4. Edition-specific operating policies

| Edition | Update posture | Primary risk | Recovery emphasis |
| --- | --- | --- | --- |
| Server | Controlled security-first updates, maintenance windows, conservative restarts | Remote downtime and critical service disruption | Out-of-band access, backups, package repair, documented restore |
| Network | Strong connectivity preflight and controlled network-stack changes | Gateway or management lockout | Console/out-of-band access, safe network recovery, configuration restore |
| Desktop | User-visible updates and reboot consent | Session interruption and incompatible local configuration | Btrfs snapshots where validated, package repair, backups, user-guided recovery |

The policies do not guarantee zero downtime or uninterrupted networking.

## 5. Alternatives considered

| Decision | Selected | Rejected as default |
| --- | --- | --- |
| U01 | Debian-native APT/dpkg | Custom package/update engine |
| U02 | Security-first, edition-aware policy | Treat all updates identically |
| U03 | Configurable conservative automation | Fully automatic updates everywhere |
| U04 | Preflight safety checks | Apply updates without preflight |
| U05 | Preserve administrator changes | Replace local configuration with defaults |
| U06 | Layered recovery with explicit limitations | Assume universal atomic rollback |
| U07 | Explicit supported release migration | Automatic major OS upgrades |
| U08 | Health validation and audit trail | Rely only on package-manager exit code |

## 6. Consequences, risks, and mitigations

**Benefits:** Compatibility with Debian maintenance, timely security patching, predictable edition behavior, administrator control, safer remote updates, preserved configuration, and more realistic failure recovery.

**Risks:** Delayed critical patches, partial dpkg transactions, repository incompatibilities, insufficient disk space, service restart failures, loss of network access, incompatible kernels/bootloaders, configuration drift, snapshot gaps, and irreversible application data migrations.

**Mitigations:** Prioritized security policy, update previews and preflight checks, explicit approval for disruptive changes, protected configuration, tested recovery paths, layered backups, staged validation, and accurate failure reporting.

A completed APT transaction is not evidence that applications or the network are healthy. A filesystem snapshot is not a replacement for application-consistent backup, and rollback may require manual intervention.

## 7. Future acceptance criteria — not executed

1. Verify all routine package updates use authenticated Debian/DesKaOne APT repositories and native dpkg semantics.
2. Test security-update classification, maintenance-window behavior, and edition-specific policy decisions.
3. Confirm automatic updates obey explicit configuration and never initiate major OS upgrades or disruptive reboots without approved policy.
4. Exercise preflight failures for low disk space, broken dependencies, held packages, package locks, and incompatible repositories.
5. Validate network and remote-management recovery planning before critical Server/Network updates.
6. Test preservation and conflict handling for modified dpkg conffiles and administrator-owned configuration.
7. Exercise interrupted package upgrades, partial installation states, repair/reconfiguration, and recovery reporting.
8. Evaluate Btrfs snapshot recovery on supported Desktop layouts, with explicit checks for bootability and excluded data.
9. Confirm ext4 Server/Network recovery procedures do not depend on nonexistent atomic filesystem snapshots.
10. Validate supported major-release migration preconditions, explicit approval, and unsupported-path rejection.
11. Test post-update service, network, security, and reboot readiness checks, including degraded outcomes.
12. Verify nonsecret audit records, recovery guidance, and backup/restore compatibility for persistent application state.

These are future validation requirements. No update or rollback implementation has been built or tested; no runtime PASS claims are made.

## 8. Deferred technical design

Concrete unattended-upgrades or scheduling configuration; security severity classification; update preview UX; exact preflight thresholds; package pinning/holds; reboot orchestration; Btrfs snapshot tooling; boot-entry selection; ext4 recovery runbooks; update journal schema; health-check thresholds; maintenance-window controls; repository transition mechanics; release migration matrices; and edition-specific operator interfaces are deferred to separately approved technical design and implementation.

## 9. Approval and scope

The project owner approved U01=A, U02=A, U03=A, U04=A, U05=A, U06=A, U07=A, and U08=A, then separately approved publication of ADR-0016 Final R1 through feature branch, commit, pull request, squash merge, and verification on `main`.

This ADR inherits ADR-0001 through ADR-0015 without reopening accepted decisions.

**Phase 0 — Architecture & Documentation Only.** No source code, update scripts, package builds, ISO/cloud-image builds, host changes, deployments, runtime tests, or GitHub Actions execution is authorized.
