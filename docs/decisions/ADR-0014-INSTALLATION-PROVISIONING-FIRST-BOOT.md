# ADR-0014 — Installation, Provisioning & First-Boot Architecture

**Project:** DesKaOne OS  
**Version:** Final R1  
**Status:** Accepted — architecture/documentation only  
**Decision date:** 2026-10-25  
**Scope:** Installation and first-boot policies for Server, Network, and Desktop editions  
**Implementation authorization:** Not granted

## 1. Context and objectives

DesKaOne OS has a Debian-native foundation and three modular editions. Installation must be predictable for physical computers, mini PCs, network appliances, and virtual/cloud hosts while preserving the approved edition-specific package, filesystem, networking, and security decisions. Provisioning must avoid destructive surprises, cloned host identities, and unrecoverable remote network changes.

This ADR establishes an architecture-level policy for installation, unattended provisioning, and first-boot readiness. It does not select final implementation scripts, image-building tools, or distribution artifacts, and it does not reopen ADR-0001 through ADR-0013.

## 2. Approved decisions

### I01 — Debian-native installation foundation

- Build on maintained Debian installation and package-management mechanisms rather than writing a wholly new installer framework.
- Layer DesKaOne branding, edition profiles, signed package sources, and documented defaults on the Debian-native foundation.
- Preserve compatibility with Debian boot, firmware, package, partitioning, and recovery conventions.
- Select exact installer components and supported boot environments in later technical design.
- Do not claim an installer, ISO, or cloud image currently exists.

### I02 — Interactive and unattended installation modes

- Support interactive installation for operator-guided systems and unattended provisioning for repeatable deployments.
- Treat unattended profiles as explicit, validated inputs; distinguish safe defaults from destructive operations.
- Require unambiguous target disk selection and explicit authorization before wiping or repartitioning storage.
- Protect unattended configuration files and secrets; avoid logging passwords, private keys, or access tokens.
- Validate required values, edition compatibility, storage constraints, and expected networking before irreversible operations.
- Do not silently fall back to a destructive action when unattended configuration is incomplete or invalid.

### I03 — Shared installation core with edition profiles

- Use a common installation foundation and edition-specific configuration/package profiles for Server, Network, and Desktop.
- Install only the packages and services required by the selected edition and approved optional modules.
- Preserve approved APT/dpkg package ownership, metapackages, dependency boundaries, and administrator override policies.
- Avoid shipping a universal fully enabled installation with all edition services preinstalled.
- Treat changing editions after installation as a separately designed migration, not an implicit installer feature.

### I04 — Safe edition-specific disk and filesystem provisioning

- Respect the approved storage architecture: ext4 as the Server/Network default and Btrfs as the Desktop default, with exact layouts deferred.
- Support guided profiles and advanced manual partitioning without silently overriding user-selected layouts.
- Display or record target device, partitions, formatting operations, and data-loss impact before destructive changes.
- Account for UEFI/boot compatibility, disk capacity, encryption requirements, recovery partitions where approved, and installation rollback limitations.
- Do not promise transactional rollback of partitioning or guaranteed recovery after a destructive operation.
- Provide clear failure handling and a documented recovery path for partially completed installations.

### I05 — Unique host identity and secure secret initialization

- Ensure each installed or cloned instance receives a unique host identity; avoid distributing reusable machine IDs or SSH host private keys in generic images.
- Initialize or regenerate `/etc/machine-id`, SSH host keys when SSH is installed/enabled, and other instance-specific identifiers through supported mechanisms at the appropriate lifecycle stage.
- Never embed shared production passwords, API keys, or private keys in install media or unattended profiles.
- Require secure administrator credential initialization, appropriate filesystem permissions, and noninteractive secret provisioning where applicable.
- Avoid exposing initial credentials through console logs, journals, images, or diagnostic exports.
- Design cloud-image identity handling so instance cloning does not inherit unique secrets.

### I06 — Safe networking and remote-access provisioning

- Apply edition-specific network configuration and firewall policies without introducing unnecessary open listeners.
- Remote management access is opt-in and must use approved authentication and security defaults.
- For remote Server and Network provisioning, require a practical fallback or recovery path before applying changes that could remove management connectivity.
- Validate interface identity, addressing, routes, DNS, and connectivity as appropriate; distinguish local link readiness from internet availability.
- Where supported, plan confirmation-based configuration application with timeout/rollback, while recognizing that some physical or cloud failures cannot be reversed remotely.
- Avoid making successful installation depend on access to a DesKaOne-operated server.

### I07 — Declarative profiles and repeat-safe provisioning

- Define versioned, schema-validated provisioning profiles for edition selection and initial configuration.
- Design steps to be idempotent or explicitly guarded so reruns do not duplicate users, regenerate persistent secrets, destroy data, or repeatedly overwrite administrator changes.
- Record bounded, nonsecret provisioning state and failures to support safe retry after interruption.
- Distinguish first-install tasks from one-time first-boot tasks and ongoing configuration management.
- Ensure failed steps are visible and recoverable; do not mark incomplete provisioning as successful.
- Preserve the separation between package-owned defaults and administrator-owned local configuration.

### I08 — First-boot readiness validation and recoverable failure

- Validate host identity, selected edition, filesystem/storage state, network configuration, essential services, and initial security posture at first boot.
- Distinguish kernel boot success, systemd service state, application readiness, and connectivity rather than equating boot completion with operational readiness.
- Record actionable failures without leaking credentials; provide CLI/local recovery paths for headless and offline scenarios.
- Do not silently disable essential security controls to obtain a passing readiness result.
- Support safe continuation/retry of incomplete first-boot steps, with explicit confirmation for destructive recovery.
- Exact checks, thresholds, timeout behavior, and presentation are deferred to technical design.

## 3. Conceptual installation lifecycle

1. **Select installation source and mode:** Debian-native installer foundation; interactive or validated unattended profile.
2. **Select edition:** Server, Network, or Desktop, mapped to approved shared-core and edition package profiles.
3. **Validate planned changes:** target disk, partition/filesystem profile, packages, network, identity, secrets, and explicit destructive authorization.
4. **Install base and edition packages:** follow Debian packaging conventions and approved defaults.
5. **Initialize unique instance identity and configuration:** do not clone persistent machine IDs or SSH host keys.
6. **Apply safe networking and access policy:** preserve recovery access and avoid unexpected exposed services.
7. **Run first-boot provisioning:** repeat-safe initialization with bounded status and failure reporting.
8. **Evaluate readiness:** system, services, application-specific checks where available, and connectivity; present actionable recovery instructions.

These are architectural stages, not an executable installer specification.

## 4. Edition-specific priorities

| Edition | Installation priorities | First-boot concerns |
| --- | --- | --- |
| Server | Headless and VPS/cloud provisioning, lean packages, ext4 baseline, remote access only when explicitly configured | Unique host/SSH identity, storage, essential services, safe remote recovery |
| Network | Gateway interfaces, routing and firewall policy, ext4 baseline, controlled access | Management reachability, interface mapping, DNS/routes, rollback and local recovery |
| Desktop | Guided interactive installation, Btrfs baseline, KDE Plasma/SDDM integration | User setup, display/session readiness, hardware/driver diagnostics |

The edition-specific details remain governed by the previously accepted architecture decisions.

## 5. Alternatives considered

| Decision | Selected | Rejected as default |
| --- | --- | --- |
| I01 | Debian-native installation foundation | Custom installer built from scratch |
| I02 | Interactive and unattended modes | Interactive-only installation |
| I03 | Shared core plus edition profiles | Universal all-components installation |
| I04 | Safe edition-specific storage profiles | Unconfirmed automatic disk destruction |
| I05 | Unique identity and secure secret initialization | Reusable cloned identity/credentials |
| I06 | Safe network provisioning and opt-in remote access | Universally enabled remote listeners |
| I07 | Declarative, validated, repeat-safe provisioning | Untracked one-shot scripts |
| I08 | Layered first-boot readiness and recoverable failure | Treating boot success as complete readiness |

## 6. Consequences, risks, and mitigations

**Benefits:** A common Debian-compatible installation foundation, consistent edition deployment, support for unattended hosts, safer storage changes, unique machine identity, controlled remote access, and diagnosable first-boot failures.

**Risks:** Destructive partitioning, unsupported firmware/boot environments, incomplete unattended profiles, leaked secrets, duplicate cloned identifiers, network lockout, partially applied provisioning, incorrect readiness checks, and incompatible hardware/cloud images. Mitigations include strict validation, explicit destructive confirmation, unique identity generation, secret minimization, recovery access planning, idempotent operations, and staged testing on representative environments.

An installer cannot guarantee recovery after disk destruction, loss of out-of-band access, or underlying hardware failure.

## 7. Future acceptance criteria — not executed

1. Verify interactive and unattended installation flows for each edition using representative hardware/VM targets.
2. Validate malformed and incomplete unattended profiles fail safely before destructive operations.
3. Test explicit disk selection, guided/manual partitioning, filesystem selection, and recovery after interrupted installation.
4. Confirm Server/Network ext4 and Desktop Btrfs defaults follow the approved storage decisions.
5. Verify only edition-appropriate packages, services, and listeners are installed or enabled.
6. Validate machine-ID and SSH-host-key uniqueness across cloned and independently installed instances.
7. Verify initial credentials, secrets, logs, and unattended configuration files do not expose reusable sensitive values.
8. Test local and remote network provisioning, connectivity validation, and recoverability after incorrect configuration.
9. Exercise repeat-safe provisioning after interrupted, partially successful, and repeated runs.
10. Validate first-boot system, service, application, and connectivity signals with accurate degraded/failure reporting.
11. Test headless rescue, offline operation, and local administrator recovery.
12. Verify compatibility with approved package management, service lifecycle, observability, and backup/recovery policies.

These are future validation requirements; no runtime tests or PASS claims are made.

## 8. Deferred technical design

Installer implementation details; bootloader and firmware matrices; ISO/cloud-image pipelines; unattended profile schema; concrete disk layouts; optional disk encryption flows; exact systemd units and first-boot commands; secrets injection; network confirmation/rollback mechanics; provisioning state storage; readiness criteria; recovery interfaces; and hardware support matrices are deferred to separately approved technical design and implementation.

## 9. Approval and scope

The project owner approved I01=A, I02=A, I03=A, I04=A, I05=A, I06=A, I07=A, and I08=A, then separately approved publication of ADR-0014 Final R1 through a feature branch, commit, pull request, squash merge, and verification on `main`.

This ADR inherits ADR-0001 through ADR-0013 without reopening accepted decisions.

**Phase 0 — Architecture & Documentation Only.** No source code, installer or provisioning scripts, host changes, ISO/cloud-image or package builds, deployments, runtime tests, or GitHub Actions execution is authorized.
