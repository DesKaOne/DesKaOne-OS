# ADR-0013 — Backup, Restore & Disaster Recovery Architecture

**Project:** DesKaOne OS  
**Version:** Final R1  
**Status:** Accepted — architecture/documentation only  
**Decision date:** 2026-10-25  
**Scope:** Shared backup and recovery policy for Server, Network, and Desktop editions  
**Implementation authorization:** Not granted

## 1. Context and goals

DesKaOne OS requires practical recovery from accidental deletion, failed updates, disk loss, corrupted service data, misconfiguration, and loss of a complete device or VPS. A single full-disk image is insufficient for granular recovery, while a simple file copy may be inconsistent for stateful applications. Backup design must respect different edition priorities, limited resources, operator control, security, and Debian-native administration. This ADR inherits ADR-0001 through ADR-0012 without reopening accepted decisions.

The objectives are to make backups restorable, preserve data and administrator configurations, support recovery when the original host is unavailable, and avoid promising universal recovery times or zero data loss.

## 2. Approved decisions

### B01 — Hybrid file-level and application-aware backup

- Support file- and directory-level backups for user data, configuration, and other selected assets.
- Use application-aware backup methods for stateful services, such as database-native logical/physical backups or coordinated consistent snapshots, selected by workload.
- Do not assume copying a live database's data directory creates a valid recoverable backup.
- Record required dependencies, application versions, consistency points, and restore ordering when needed.
- Distinguish OS-reproducible components from unique data and configuration; do not require backing up replaceable package binaries by default.
- Define exclusion policies for transient files, caches, sockets, and other non-restorable or sensitive material.

### B02 — Local and optional remote/offsite destinations

- Support local external storage, NAS, and compatible remote/offsite storage as selectable destinations; no cloud vendor is mandatory.
- Avoid treating a backup stored on the same physical device or failure domain as sufficient disaster recovery.
- Recommend separate failure domains, including offline or immutable copies where feasible, according to workload criticality.
- Treat network failure, unavailable storage, interrupted transfers, and partial uploads as expected error conditions with visible outcomes.
- Require explicit operator configuration for remote destinations and associated credentials; backup and restore must not depend on a DesKaOne-hosted service.
- A 3-2-1-style strategy is guidance, not a universal default guarantee.

### B03 — Profile-based scheduling and retention

- Allow manual backup operations; scheduled automation is opt-in and edition/workload-specific.
- Define frequency, retention, storage quotas, cleanup, and failure reporting per profile, rather than enforcing one global daily schedule.
- Account for available space, transfer bandwidth, power state, and backup duration; prevent unbounded local disk usage.
- Protect the last known good recoverable backup from accidental deletion through retention logic where technically feasible.
- Differentiate successful backup creation from verified recoverability and surface skipped, stale, and failed backups.
- Do not silently purge snapshots or archives outside the documented retention policy.

### B04 — Optional encryption with strong key recovery

- Support strong authenticated encryption for backups; recommend it for offsite, portable, or sensitive data.
- Allow policy-based opt-in where encryption is not required, without misrepresenting unencrypted archives as secure.
- Keep decryption keys, recovery material, and access controls separate from backup data where feasible.
- Document secure generation, storage, rotation, loss, compromise, and recovery procedures for encryption keys.
- Verify that recovery personnel can access required keys before relying on an encrypted backup.
- Avoid recording keys or secrets in logs, support bundles, or backup manifests.

### B05 — Integrity verification and periodic restore drills

- Check backup completeness and integrity using appropriate authenticated checks, manifests, checksums, and/or backup-tool verification features.
- Validate that application-aware backups can actually be restored to a consistent state.
- Plan periodic restore drills on isolated test targets appropriate to the edition and workload, with recorded outcomes and corrective actions.
- Treat an archive creation success message as insufficient evidence of recovery readiness.
- Define verification frequency and representative restore scenarios in later technical design; no tests are claimed by this ADR.
- Ensure verification does not accidentally overwrite production data.

### B06 — Granular restore, service restore, and system rebuild

Provide three recovery modes:

1. **File restore:** recover selected files, directories, permissions, ownership, and relevant metadata.
2. **Service restore:** recover application configuration and consistent state with dependency and version checks.
3. **System rebuild:** reinstall/reprovision a compatible DesKaOne OS edition, then restore selected configuration, service state, and user data.

- Bare-metal image restore is optional and subject to platform and hardware validation.
- Avoid automatic destructive restore actions; require target validation, previews where practical, and explicit confirmation.
- Plan rescue/offline procedures for systems that cannot boot and for VPS hosts that must be rebuilt elsewhere.
- Preserve edition compatibility; cross-edition conversion is not implicitly approved by this ADR.

### B07 — Workload-specific RPO and RTO objectives

- Define **Recovery Point Objective (RPO)** as the maximum acceptable age of recoverable data, and **Recovery Time Objective (RTO)** as the target time to restore required service.
- Set targets per workload and device profile, reflecting data change rate, backup interval, transfer cost, and operational constraints.
- Avoid one universal RPO/RTO across Server, Network, and Desktop.
- Do not publish untested numerical targets or imply zero data loss or guaranteed recovery under all disasters.
- Evaluate actual recovery results against targets during future drills and adjust plans accordingly.

### B08 — Least privilege, protected copies, and data lifecycle

- Limit backup creation, deletion, reading, and restoration permissions according to least privilege.
- Prefer write-restricted, offline, versioned, or immutable copies where supported, to reduce accidental deletion and ransomware impact.
- Separate routine backup credentials from broad administrative or destructive access where possible.
- Protect manifests and restore metadata; record relevant backup/restore events without exposing secret material.
- Specify retention expiry, secure disposal expectations, privacy handling, and ownership for stored archives.
- Treat backup archives as sensitive data even when encrypted; explicitly authorize access and sharing.

## 3. Edition-specific priorities

| Edition | Primary backup assets | Recovery emphasis |
| --- | --- | --- |
| Server | Service/database state, application data, host configuration, secrets managed through appropriate secure procedures | Workload consistency, VPS migration/rebuild, service restart ordering |
| Network | Firewall, routing, VPN, DNS, gateway configuration, credentials managed securely | Safe rollback, connectivity recovery, local console/rescue access |
| Desktop | User files, home settings, KDE configuration, application state as appropriate | Selective file restore, user-profile recovery, reinstall and restore |

All editions share the same policy framework but need not ship or enable identical backup tools.

## 4. Alternatives considered

| Decision | Selected | Rejected as universal default |
| --- | --- | --- |
| B01 | Hybrid file and application-aware backup | Full-disk images only |
| B02 | Local with optional offsite/remote storage | Same-device/local-only strategy |
| B03 | Per-profile schedule and retention | Universal fixed daily schedule |
| B04 | Optional strong encryption plus key recovery | Unencrypted-only archives |
| B05 | Integrity verification and restore drills | Backup-success message as proof |
| B06 | File, service, and system-rebuild recovery | Full-system restore only |
| B07 | Workload-specific RPO/RTO | Universal numerical recovery target |
| B08 | Least privilege and protected copies | Broadly writable backup repository |

## 5. Risks, mitigations, and consequences

**Benefits:** Flexible recovery, reduced dependence on one storage destination, better consistency for stateful services, recoverable encryption design, and realistic recovery objectives.

**Risks:** Backups may be incomplete or inconsistent; snapshots may share the same failure domain; remote storage or keys may become inaccessible; archives may expose sensitive data; retention may delete needed restore points; malicious or accidental deletion may affect online backups; rebuilds may face version or hardware incompatibilities. Mitigations include explicit backup inventories, application-specific consistency controls, independent copies, credential separation, integrity checks, restore drills, conservative retention, documented key recovery, and validated target compatibility.

No single backup technique eliminates all failure modes. Backups do not replace application high availability or transactional durability.

## 6. Future acceptance criteria — not executed

1. Validate file-level backup and restore, including permissions, ownership, symlinks, and selected metadata.
2. Verify consistent backup/restore for representative databases and stateful applications.
3. Test local and optional offsite destinations, network interruption, incomplete uploads, and insufficient storage.
4. Exercise per-profile schedules, retention, quota enforcement, failure visibility, and protection of known-good restore points.
5. Verify encrypted backup recovery with separately held keys; test key-loss and compromised-key procedures.
6. Verify integrity checks and isolated restore drills without modifying production data.
7. Test granular file restore, service restoration with dependencies, and system rebuild on compatible targets.
8. Evaluate workload-specific RPO/RTO against measured drill results rather than assumptions.
9. Test least-privilege access, protected/immutable or offline copies where available, and safe deletion policies.
10. Validate edition-specific Server, Network, and Desktop recovery procedures, including network access and offline rescue.
11. Verify logs and manifests do not expose credentials, encryption keys, or sensitive restored data.
12. Validate backup-tool installation/removal and upgrades without changing unrelated edition packages or administrator overrides.

All items are future validation requirements; **no PASS status or runtime test is claimed**.

## 7. Deferred technical design

Specific backup utilities and formats; application-specific backup adapters; storage backends; retention numbers; encryption algorithms and key-management procedures; systemd timers and scheduling; restore UI/CLI; recovery media; snapshot integration with ext4/Btrfs where supported; network configuration rollback; disaster runbooks; and numerical RPO/RTO targets remain subject to separately approved technical design and implementation.

## 8. Approval and scope

The project owner approved B01=A, B02=A, B03=A, B04=A, B05=A, B06=A, B07=A, and B08=A, then separately approved publication of ADR-0013 Final R1 through a feature branch, commit, pull request, squash merge, and verification on `main`.

This ADR inherits ADR-0001 through ADR-0012 without reopening previously approved decisions.

**Phase 0 — Architecture & Documentation Only.** No source code, host changes, backup deployment, package or ISO/image builds, runtime testing, or GitHub Actions execution is authorized.
