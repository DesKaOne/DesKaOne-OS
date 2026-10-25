# ADR-0012 — Observability & System Diagnostics Architecture

**Project:** DesKaOne OS  
**Version:** Final R1  
**Status:** Accepted — architecture/documentation only  
**Decision date:** 2026-10-25  
**Scope:** Shared observability and diagnostics across Server, Network, and Desktop editions  
**Implementation authorization:** Not granted

## 1. Context and objectives

DesKaOne OS must be diagnosable on small VPS instances, network gateways, and KDE desktop systems, including during internet outages and rescue scenarios. The baseline must be lightweight, local-first, secure, and consistent with the approved systemd service lifecycle. Advanced monitoring and remote integrations remain optional. This ADR defines the new observability policy; ADR-0001 through ADR-0011 remain accepted without re-review.

## 2. Approved decisions

### O01 — Native Linux and systemd baseline

- Use existing Linux and Debian facilities as the default source of operational signals: systemd unit state, systemd-journald, `/proc`, `/sys`, and relevant kernel/service status interfaces.
- Avoid requiring an always-running proprietary or DesKaOne-specific monitoring agent in the shared core.
- Support local, offline diagnostics and recovery even when DNS, external APIs, or a dashboard are unavailable.
- Treat metrics availability and access privileges as capability-dependent; do not promise identical measurements on all kernels, virtual machines, or hardware.
- Avoid unnecessary background polling and persistent writes.

### O02 — Bounded journald logging and retention

- Use journald as the primary local system logging baseline, with storage mode, quotas, retention, and cleanup policies defined for each resource profile during technical design.
- Ensure logs cannot consume unbounded disk space; account for both persistent and volatile journal configurations.
- Preserve critical boot, service, authentication, update, and security-event diagnostics where feasible.
- Distinguish journald's own retention/vacuum mechanisms from external logrotate-managed text logs; do not assume logrotate controls binary journals.
- Define disk-pressure and failure behavior, including when persistent logs cannot be written.
- Centralized logging is opt-in and must not be a prerequisite for local operation.

### O03 — Lightweight local metrics, optional exporters

- Expose or document locally obtainable CPU, memory, storage, filesystem, network, and service-state signals without mandating a time-series database.
- Separate live metric collection from historical storage and dashboard presentation.
- Offer exporters, monitoring collectors, Prometheus-compatible integration, dashboards, and alerting stacks as optional APT-managed modules.
- Minimize collection overhead and avoid unverified polling, retention, or hardware capacity claims.
- Define metric names, units, permission boundaries, and availability only in subsequent technical design.

### O04 — Layered health model

Health is explicitly divided into four non-equivalent layers:

1. **System health:** CPU/memory pressure, disk capacity, filesystem and boot-related conditions.
2. **Service state:** systemd loaded/active/failed states, exit codes, dependency and restart-limit failures.
3. **Application health:** workload-specific readiness, functionality, or dependency checks when a trustworthy probe exists.
4. **Connectivity:** interface/link state, address, route, DNS, and endpoint reachability where relevant.

- A systemd `active` state alone does **not** prove application readiness.
- A failed external endpoint probe alone does **not** prove the local system is unhealthy.
- Prefer explicit `healthy`, `degraded`, `unhealthy`, and `unknown/unavailable` interpretations with documented evidence and freshness; exact mappings are deferred.
- Health checks must have bounded timeouts and avoid destabilizing the system under investigation.

### O05 — Local CLI, optional dashboards

- Provide an offline-capable local diagnostic workflow using Debian/systemd command-line tools; any future DesKaOne wrapper CLI is optional and requires separate implementation approval.
- Keep CLI-based inspection available for headless Server and rescue situations.
- Allow edition-specific UI integration: the Network Edition may expose approved diagnostic information in its web dashboard; Desktop may integrate with local graphical tooling; Server need not run a web dashboard.
- Do not create mandatory remote listeners or management ports merely for observability.
- Apply authorization and least privilege to diagnostics exposing sensitive state.

### O06 — Local events first; remote alerts opt-in

- Record actionable local events and health transitions even without internet access.
- Treat remote notifications, webhook integrations, mail alerts, and centralized alert managers as explicitly enabled optional modules.
- Design severity levels, deduplication, cooldowns, recovery notifications, and noise suppression to avoid alert storms.
- Distinguish actionable failures from transient expected behavior; no hard-coded universal alert thresholds are approved.
- Never allow failure of an external alerting service to block normal boot or core operations.

### O07 — Privacy, security, and minimal data

- **No automatic outbound telemetry**, crash reporting, log uploads, device inventory transmission, or diagnostic sharing to DesKaOne or third parties.
- Minimize collection to operationally relevant information, with documented purpose and retention.
- Restrict journal, metrics, and diagnostic access using existing OS permission and privilege boundaries.
- Treat logs as potentially sensitive: redact or exclude passwords, API keys, tokens, private keys, credentials, personal information, and other secrets from exported materials.
- Prevent observability endpoints from unintentionally exposing internal topology, credentials, or administrator actions.
- Require explicit informed authorization before any external transmission or sharing.

### O08 — Local, manual, sanitized diagnostic bundles

- Plan an opt-in, locally generated support/recovery bundle that collects bounded relevant system/version information, service states, selected logs, and configuration summaries.
- Exclude secret-bearing files by default and apply allowlists, redaction, and conservative access permissions.
- Support administrator preview, explicit confirmation, and local deletion/retention control before any sharing.
- Recognize that automated redaction is imperfect: warn that manual review is required and never claim a bundle is guaranteed free of secrets.
- Do not auto-upload bundles or crash reports; support workflows must remain possible offline.
- Define exact fields, commands, file size limits, and bundle format in later technical design.

## 3. Edition-specific diagnostic focus

| Edition | Diagnostic priorities | Optional presentation |
| --- | --- | --- |
| Server | Headless access, service failures, disk/storage pressure, SSH, updates, resource constraints | Exporters and remote monitoring |
| Network | Interface/link, routing, firewall, DNS, VPN, gateway reachability, rollback events | Existing Network dashboard and CLI |
| Desktop | Boot, user session, KDE/SDDM, drivers, device state, application failures | Local graphical integration |

These differences specialize the same minimal shared baseline without introducing cross-edition service dependencies.

## 4. Alternatives considered

| Decision | Selected | Rejected as default |
| --- | --- | --- |
| O01 | Native Linux/systemd observability | Mandatory monitoring agent |
| O02 | Quota-controlled local journald | Mandatory centralized logging |
| O03 | Lightweight local metrics, optional exporters | Mandatory Prometheus/Grafana stack |
| O04 | Layered health assessment | Only systemd `active` status |
| O05 | Local CLI, optional dashboard | Mandatory web dashboard |
| O06 | Local events, optional remote alerts | Mandatory remote alerting |
| O07 | Minimal private data, no automatic telemetry | Automatic centralized telemetry |
| O08 | Manual sanitized diagnostic bundle | Automatic crash-report upload |

## 5. Consequences, tradeoffs, and risks

**Benefits:** Low default overhead, useful offline diagnosis, fewer unnecessary services and network listeners, clear health semantics, explicit opt-in for remote tooling, and stronger privacy by default.

**Risks:** Limited historical visibility without optional storage, inconsistent platform metrics, journal loss on volatile storage, excessive retention on small disks, incorrect health inference, noisy alerts, sensitive data embedded in logs, and imperfect bundle sanitization. Mitigations include bounded quotas, source/freshness annotations, layered health interpretation, explicit alert policy, least-privilege access, safe collection defaults, and mandatory user review before sharing.

## 6. Future acceptance criteria — not executed

1. Verify local diagnostics during internet/DNS outages and without an installed monitoring agent.
2. Verify journald storage/retention policy, disk-pressure behavior, and persistent versus volatile modes.
3. Measure CPU, memory, I/O, and storage overhead of baseline collection on representative Server, Network, and Desktop profiles.
4. Validate live metrics against underlying OS signals, including missing or inaccessible metrics.
5. Exercise all four health layers and ensure service-active is not equated with application-ready.
6. Validate local CLI operation in headless and rescue contexts, including privilege boundaries.
7. Exercise alert severity, deduplication, cooldown, transient errors, and remote integration failures.
8. Verify that no default outbound telemetry or automatic crash/diagnostic upload occurs.
9. Test optional exporter/dashboard installation and removal without disrupting shared core.
10. Verify support-bundle size limits, file permissions, exclusion rules, redaction, preview, and manual approval before sharing.
11. Test sensitive-data exposure paths in logs, endpoints, and diagnostic bundles.
12. Validate edition-specific network, desktop, and server diagnostics without accidental cross-edition dependencies.

These are future verification requirements, **not PASS claims**.

## 7. Deferred technical design

Specific journald quotas and retention durations; local CLI command set; metrics schema and collection frequency; optional exporters; health-state mapping and probe contracts; alert thresholds and destinations; Network/desktop UI integrations; diagnostic bundle allowlists, format, redaction strategy, and secure handling; and performance measurements remain separately approved technical-design tasks.

## 8. Approval and scope

The project owner approved O01=A, O02=A, O03=A, O04=A, O05=A, O06=A, O07=A, and O08=A, then separately approved publication of ADR-0012 Final R1 via feature branch, commit, pull request, squash merge, and verification on `main`.

This ADR inherits ADR-0001 through ADR-0011 without reopening accepted decisions.

**Phase 0 — Architecture & Documentation Only.** No code, host configuration changes, monitoring agent deployment, package or ISO/image builds, runtime tests, or GitHub Actions execution is authorized.
