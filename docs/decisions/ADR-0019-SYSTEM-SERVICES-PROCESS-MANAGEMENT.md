# ADR-0019 — System Services & Process Management Architecture

**Project:** DesKaOne OS  
**Version:** Final R1  
**Status:** Accepted — architecture/documentation only  
**Decision date:** 2026-10-25  
**Scope:** Service supervision, startup, dependencies, isolation, resource management, logging, failure recovery, and administration across Server, Network, and Desktop editions  
**Implementation authorization:** Not granted

## 1. Context and objectives

DesKaOne OS is a Debian Stable-based Linux distribution with Server, Network, and Desktop editions. Service lifecycle design must reuse Debian/systemd facilities, remain resource-efficient, protect management connectivity and critical networking, and support predictable diagnostics. Headless servers, network gateways, and KDE Plasma desktops require distinct startup profiles and recovery priorities.

This ADR establishes service management policy, not an implementation. It inherits ADR-0001 through ADR-0018 without reopening accepted decisions.

## 2. Approved decisions

### S01 — systemd-native service management

- Use systemd as the authoritative system and user service manager, including units, targets, sockets, timers, and cgroup integration where appropriate.
- Prefer Debian-supported systemd mechanisms over a custom supervisor or duplicate service-control layer.
- Respect system vs. user service boundaries and avoid unapproved user services gaining system-level privileges.
- Manage unit dependencies and lifecycle through supported systemd facilities; exact unit templates and packaging are deferred.
- Do not assume all workloads require persistent background daemons; prefer timers and socket activation where appropriate.

### S02 — Minimal, edition-aware startup profiles

- Activate only required services by default, with edition-specific profiles and administrator-controlled optional services.
- **Server:** prioritize headless boot, storage, core networking, SSH/remote management when configured, and explicitly enabled workloads.
- **Network:** prioritize stable interface configuration, firewall, routing, and approved optional DNS/DHCP or gateway services; preserve management reachability.
- **Desktop:** prioritize SDDM, KDE Plasma session requirements, NetworkManager, and relevant user services without unnecessary server/gateway daemons.
- Avoid enabling all installed units indiscriminately or treating installed packages as authorization to expose services.
- Keep exact targets, unit enablement matrices, and package dependencies for later technical design.

### S03 — Explicit dependencies, ordering, and readiness

- Express actual unit dependencies and ordering using systemd's native relationships, with clear distinctions among requirements, preferences, and startup sequencing.
- Avoid fixed sleeps as a substitute for reliable readiness signals.
- Distinguish process started, unit active, application ready, and end-to-end service healthy.
- Do not universally require network-online.target for every service; use it only when justified and understand its limitations.
- Detect dependency cycles and critical-path startup regressions during future validation.
- Document application-specific readiness protocols where systemd activation alone cannot establish readiness.

### S04 — Least-privilege systemd hardening

- Prefer dedicated service identities, least privilege, capability restrictions, filesystem isolation, and systemd sandboxing appropriate to each service.
- Use approved credential handling rather than embedding secrets in unit files, command-line arguments, or logs where avoidable.
- Evaluate compatibility before applying restrictions such as ProtectSystem, PrivateTmp, NoNewPrivileges, capability bounding, or syscall filters.
- Treat privileged network, storage, and boot services as special cases requiring explicit security review and functional validation.
- Do not impose one universal hardening profile that silently breaks critical services.

### S05 — cgroups-based resource controls

- Use systemd/cgroups facilities for CPU, memory, I/O, process/task, and related resource controls where appropriate.
- Define edition-aware and workload-aware budgets rather than applying the same rigid limits to all services.
- Protect critical services and avoid resource settings that destabilize boot, storage, network management, or administrative access.
- Prefer observability and measured capacity planning before imposing aggressive limits.
- Distinguish soft controls from hard limits and document OOM, throttling, and dependency effects.
- Exact values, slice layouts, and per-unit policies are deferred to technical design.

### S06 — journald-first logging with retention controls

- Use systemd-journald as the baseline for service event collection and diagnosis, with documented persistent/volatile storage choices.
- Bound log retention, storage use, rate, and rotation to protect disks and resource-constrained systems.
- Support structured fields where useful while keeping standard Debian/Linux tooling accessible.
- Do not log passwords, API tokens, private keys, service credentials, or other secrets; redact sensitive identifiers in shared diagnostics.
- Define optional forwarding/export as a separately approved and secured integration, not an automatic data upload.
- Preserve sufficient nonsecret context to correlate failures, restarts, health checks, and administrative actions.

### S07 — Bounded restart and health-aware recovery

- Configure restart behavior according to service semantics; use rate limits, backoff or bounded retry strategies where supported.
- Avoid infinite rapid restart loops, repeated resource exhaustion, and false healthy status after a process restarts.
- Combine systemd failure states with service-specific readiness/health signals when needed.
- Expose degraded status and actionable diagnostics after unsuccessful recovery.
- Consider dependency impact before automatically restarting critical network, storage, or gateway components.
- Recovery is best effort: it cannot guarantee uninterrupted connections or repair every software/hardware fault.

### S08 — Declarative lifecycle policy and safe administration

- Describe service enablement, dependency, hardening, resource, and recovery policy in reviewable configuration under administrator control.
- Validate requested enable/disable/start/stop/restart/reload/update operations against permissions, dependency impact, and critical-service safeguards.
- Protect SSH, network management, storage, firewall, routing, and essential boot/session services from accidental remote lockout.
- Require appropriate confirmation and feasible rescue paths for disruptive changes; never silently claim recovery is guaranteed.
- Preserve administrator-owned overrides and support a traceable, redacted audit trail of configuration and lifecycle changes.
- Do not allow an unprivileged dashboard or UI to bypass systemd/polkit or other approved authorization boundaries.

## 3. Conceptual service lifecycle

1. **Define:** load edition-aware service policy, unit ownership, administrator overrides, and intended lifecycle action.
2. **Validate:** check dependencies, privileges, sandbox compatibility, resource budgets, and critical-service impact.
3. **Authorize:** confirm the actor has permission and obtain explicit consent for disruptive operations.
4. **Apply:** use supported systemd mechanisms for the approved service lifecycle action.
5. **Observe:** assess unit state, application readiness, journald diagnostics, and relevant cgroup signals.
6. **Recover or escalate:** attempt bounded restart/recovery where safe, otherwise report degraded state and administrator action.
7. **Record:** maintain nonsecret audit information and useful troubleshooting context.

This describes future architecture; no custom service orchestration engine or runtime implementation is authorized.

## 4. Edition-specific policy

| Edition | Startup priorities | Critical safeguards | Optional services |
| --- | --- | --- | --- |
| Server | Minimal headless boot, storage, network, remote administration | Protect SSH, network, storage, and core system availability | Administrator-enabled server workloads |
| Network | Network configuration, firewall, routing, management | Protect gateway paths, multi-NIC ownership, DNS/DHCP dependencies, remote access | Explicitly configured network services |
| Desktop | SDDM, KDE Plasma, NetworkManager, user session services | Protect login/session readiness and connectivity | User-approved desktop/background services |

Installed packages do not automatically authorize service enablement, privileged execution, or exposed listening sockets.

## 5. Alternatives considered

| Decision | Selected | Rejected as default |
| --- | --- | --- |
| S01 | systemd-native service management | Custom process supervisor |
| S02 | Minimal, edition-aware startup | Enable all installed services |
| S03 | Explicit dependencies and readiness | Fixed-delay startup sequencing |
| S04 | Least-privilege systemd hardening | Broad privileges by default |
| S05 | cgroups-based resource controls | No resource governance |
| S06 | journald-first logging with retention | Unmanaged per-service logs |
| S07 | Bounded restart and health-aware recovery | Unlimited restart on every failure |
| S08 | Declarative policy and safe lifecycle operations | Unrestricted service operations |

## 6. Consequences, risks, and mitigations

**Benefits:** alignment with Debian tooling, fewer redundant daemons, more predictable startup, smaller attack surface, resource accountability, consistent diagnostics, and safer service administration.

**Risks:** misconfigured dependencies, readiness misclassification, hardening incompatibilities, OOM or throttling of critical services, disk pressure from logs, leaked secrets, restart storms, and remote lockout from service operations.

**Mitigations:** edition-specific defaults, dependency/readiness validation, staged hardening, measured resource budgets, journald retention and redaction, bounded recovery, explicit authorization, and documented console/out-of-band recovery.

No service manager can guarantee recovery from every kernel, hardware, storage, network, or infrastructure failure.

## 7. Future acceptance criteria — not executed

1. Confirm systemd remains the authoritative manager without a duplicate process supervisor.
2. Validate minimal startup sets for Server, Network, and Desktop editions and ensure optional services remain disabled by default.
3. Verify system/user unit isolation and the absence of accidental privileged service enablement.
4. Test dependency ordering, readiness distinctions, startup cycles, and network-online usage where justified.
5. Validate dedicated service identities, credential handling, capability restrictions, and sandbox compatibility.
6. Exercise representative CPU, memory, I/O, and task limits while preserving critical system availability.
7. Confirm journald retention/rate limits and disk-usage controls, including small-disk conditions.
8. Verify logs and diagnostic exports redact secrets and do not upload automatically.
9. Test bounded restart behavior, failure escalation, and degraded state after recovery exhaustion.
10. Validate critical-service protections for SSH, storage, networking, firewall, gateway, and login/session functions.
11. Confirm administrator-owned overrides are preserved and lifecycle operations have appropriate authorization and audit records.
12. Verify clear recovery guidance for cases that cannot be repaired remotely.

These are future validation requirements; no units, service configuration, cgroup policy, monitoring, deployment, or runtime tests have been implemented or executed.

## 8. Deferred technical design

Exact unit and target inventories, edition enablement matrices, dependency graphs, readiness protocols, service identities, sandbox settings, credentials distribution, slice layouts, resource limits, journald storage budgets, health probes, restart thresholds, administrator authorization rules, audit schema, UI/CLI integration, and service-specific recovery runbooks are deferred to separately approved technical design and implementation.

## 9. Approval and scope

The project owner approved S01=A, S02=A, S03=A, S04=A, S05=A, S06=A, S07=A, and S08=A, then separately approved publication of ADR-0019 Final R1 through feature branch, commit, pull request, squash merge, and verification on `main`.

This ADR inherits ADR-0001 through ADR-0018 without reopening accepted decisions.

**Phase 0 — Architecture & Documentation Only.** No source code, service-unit changes, system configuration changes, package/image builds, deployments, runtime tests, or GitHub Actions execution is authorized.
