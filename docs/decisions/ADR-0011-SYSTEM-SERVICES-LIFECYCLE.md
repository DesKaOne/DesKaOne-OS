# ADR-0011 — System Services & Lifecycle Architecture

**Project:** DesKaOne OS  
**Version:** Final R1  
**Status:** Accepted — architecture/documentation only  
**Decision date:** 2026-10-25  
**Scope:** Shared system service policy across Server, Network, and Desktop editions  
**Implementation authorization:** Not granted

## 1. Context

DesKaOne OS uses Debian 13 (Trixie), systemd, and edition-specific modular packages. Services must start and stop predictably, recover from transient failures without uncontrolled loops, respect resource constraints, preserve administrator overrides, and remain diagnosable on small VPS systems and desktop or network appliances. This ADR defines shared service-lifecycle policy without reopening ADR-0001 through ADR-0010.

## 2. Approved architecture decisions

### L01 — Native systemd service management

- Use Debian's native **systemd** as the primary service and lifecycle manager.
- Use standard `service`, `socket`, `timer`, `target`, `path`, and related unit types only where appropriate to the workload.
- Avoid installing a second mandatory service supervisor.
- Express genuine ordering and requirement relationships explicitly; distinguish `Wants=`, `Requires=`, `After=`, and `Before=` rather than assuming ordering implies a hard dependency.
- Keep shared service policy distinct from edition-specific service inventories.

### L02 — Minimal service activation

- Enable only essential, edition-appropriate services by default. Installing a package does not by itself justify enabling an unrelated daemon or network listener.
- Make additional services opt-in through documented administrator actions or explicitly authorized provisioning.
- Apply socket and timer activation selectively when they reduce idle overhead without changing expected security or behavior.
- Document service exposure and startup dependencies for Server, Network, and Desktop independently.
- Preserve required Debian baseline services and approved edition defaults; do not indiscriminately disable upstream units.
- Do not silently open ports or weaken firewall policy when optional modules are installed.

### L03 — Controlled restart and failure policy

- Use workload-appropriate restart strategies, such as `Restart=on-failure`, when safe.
- Bound restart attempts using systemd start-rate limits (`StartLimitIntervalSec=` and `StartLimitBurst=`) and appropriate retry delay (`RestartSec=`); select actual values during technical design.
- Avoid endless rapid restart loops, especially for persistent configuration errors or state corruption.
- Expose failed/degraded state through systemd and logs; define operator intervention and recovery for repeated failures.
- Distinguish transient processes, one-shot jobs, and long-running daemons; not all units should restart automatically.
- Never treat automatic restarts as a substitute for application-level correctness, durability, or high availability.

### L04 — Workload-specific resource management

- Use systemd's cgroup-based resource controls, with compatible kernel/cgroup capabilities validated for the target platform.
- Consider `MemoryHigh=`, `MemoryMax=`, `CPUQuota=`, `TasksMax=`, and I/O controls for services that benefit from them.
- Avoid universal hard limits that could destabilize databases, critical network services, login access, or small-memory VPS hosts.
- Prefer measured, workload-specific profiles and document behavior under memory pressure, OOM, disk pressure, and service overload.
- Do not publish untested resource-limit defaults or performance guarantees.

### L05 — Progressive service hardening

- Apply least privilege and systemd sandboxing per unit after compatibility validation.
- Evaluate `NoNewPrivileges=`, `ProtectSystem=`, `PrivateTmp=`, capability restrictions, filesystem access, device access, and network namespace restrictions as appropriate.
- Preserve functionality for legitimate workloads; explicitly document necessary exceptions.
- Coordinate systemd sandboxing with AppArmor, nftables, and edition-specific requirements.
- Avoid a blanket hardening preset that breaks required services, containers, routing, desktop sessions, or recovery access.

### L06 — Lightweight health and diagnostics

- Use systemd unit state and **journald** as the baseline operational diagnostics.
- Expose startup failures, restart throttling, exit status, dependency failures, and relevant security events without leaking secrets.
- Provide optional application-specific readiness/liveness checks only where reliable signals exist; a unit being `active` does not necessarily mean the application is healthy.
- Make metrics exporters, alerting, and centralized monitoring optional APT modules, not mandatory shared-core dependencies.
- Plan bounded log retention and disk-pressure behavior consistent with ADR-0009.

### L07 — Graceful shutdown, maintenance, and recovery

- Prefer graceful termination with workload-specific `TimeoutStopSec=`, ordering, and appropriate signals.
- For services supporting it, plan draining of connections, flushing of durable state, and controlled completion of in-flight work.
- Do not claim uninterrupted connections or zero data loss where applications, network paths, or power failures cannot guarantee them.
- Define safe escalation when a service fails to stop, and document backup, restore, and rescue procedures for stateful workloads.
- Ensure critical network and remote-management shutdown ordering does not unnecessarily block recovery.
- Plan maintenance coordination for security updates and controlled reboots; never enable uncontrolled automatic reboots.

### L08 — Package-owned units, administrator-owned overrides

- Distribute vendor unit files through Debian/DesKaOne packages in the appropriate vendor unit directories.
- Preserve administrator customizations through systemd drop-in files and other supported overrides under `/etc/systemd/system`; do not silently overwrite local modifications.
- Apply Debian package lifecycle conventions for installation, upgrades, removal, service enablement, and daemon reload.
- Validate changes to vendor unit definitions and document upgrade/migration impact before deployment.
- Do not destroy local state, secrets, or administrator overrides on ordinary package removal; explain purge behavior separately.

## 3. Edition-specific boundaries

| Edition | Lifecycle priorities | Not a default requirement |
| --- | --- | --- |
| Server | Minimal headless service inventory, SSH recovery, controlled resource use, stateful shutdown | KDE or gateway daemons |
| Network | Network-critical ordering, firewall/routing continuity, safe rollback and remote access | Desktop stack or general-purpose server applications |
| Desktop | User-session service behavior, SDDM/Plasma integration, sleep/shutdown compatibility | Gateway daemons or full server monitoring stack |

These priorities inherit previously accepted edition architecture and do not change those decisions.

## 4. Alternatives considered

| Decision | Selected | Rejected as default |
| --- | --- | --- |
| L01 | Native systemd | Mandatory extra supervisor |
| L02 | Minimal enabled-by-default services | Auto-enable all package daemons |
| L03 | Bounded restarts and visible failure | Unbounded restart loops |
| L04 | Per-service cgroup profiles | No resource policy |
| L05 | Progressive per-service hardening | Universal aggressive sandboxing |
| L06 | systemd/journald baseline, optional checks | Mandatory full monitoring agent |
| L07 | Graceful, ordered shutdown and recovery | Uniform forced termination |
| L08 | Vendor unit plus local administrator drop-ins | Overwrite administrator configuration |

## 5. Consequences and risks

**Benefits:** Consistent Debian-native operations, small default footprint, diagnosable failures, reduced restart storms, targeted resource isolation, safer shutdown, and durable administrator customizations.

**Risks:** Incorrect unit dependency graphs can deadlock startup; overly strict limits can trigger OOM or degraded performance; restart policy can mask defects; sandboxing can block valid I/O; graceful shutdown timeouts may be insufficient; package upgrades can disrupt services; `active` state can be mistaken for application readiness. Mitigate with workload-specific validation, explicit exceptions, bounded retries, log visibility, documented recovery, and staged lifecycle testing.

## 6. Future acceptance criteria — not yet executed

1. Verify boot ordering and dependency graphs across Server, Network, and Desktop.
2. Confirm only approved default services and listeners are enabled per edition.
3. Exercise failure/restart behavior, start-rate limits, permanent failure visibility, and manual recovery.
4. Measure resource pressure, cgroup limits, OOM outcomes, and performance on representative small VPS and other target systems.
5. Validate least-privilege sandboxing, AppArmor interoperability, and workload-specific exceptions.
6. Verify systemd state, journald diagnostics, bounded retention, and avoidance of secret exposure.
7. Test graceful stop, timeout escalation, connection drain where supported, and stateful service recovery.
8. Test service behavior during package install, upgrade, remove, and purge.
9. Verify vendor unit updates preserve administrator drop-ins and settings.
10. Validate network/SSH recovery, firewall continuity, and controlled reboot coordination.

No tests, deployments, or implementations are claimed by this document.

## 7. Deferred technical design

Specific unit files, enablement presets, timer schedules, restart and timeout values, cgroup resource limits, hardening directives, per-edition dependency maps, application health-check contracts, journald quotas, package maintainer scripts, and recovery runbooks are deferred to separately approved technical design and implementation.

## 8. Approval and scope

The project owner approved L01=A, L02=A, L03=A, L04=A, L05=A, L06=A, L07=A, and L08=A, then separately approved publication of this Final R1 through a feature branch, commit, pull request, squash merge, and verification on `main`.

This ADR inherits ADR-0001 through ADR-0010 without reopening previously approved decisions.

**Phase 0 — Architecture & Documentation Only.** No source code, service unit deployment, host changes, package or ISO/image build, runtime testing, or GitHub Actions execution is authorized.
