# ADR-0020 — Observability, Logging & System Diagnostics Architecture

**Project:** DesKaOne OS  
**Version:** Final R1  
**Status:** Accepted — architecture/documentation only  
**Decision date:** 2026-10-26  
**Scope:** Metrics, logs, health, alerting, diagnostics, interfaces, retention, and telemetry resource governance across Server, Network, and Desktop editions  
**Implementation authorization:** Not granted

## 1. Context and objectives

DesKaOne OS is a Debian Stable-based Linux distribution with Server, Network, and Desktop editions. Operators need useful system health and troubleshooting data without mandatory cloud connectivity, excessive monitoring overhead, or accidental exposure of secrets. Headless servers, network gateways, and KDE Plasma desktops require different views and data collection priorities.

This ADR defines an architecture-level observability policy built around established Linux facilities. It inherits ADR-0001 through ADR-0019 without reopening accepted decisions. This document does not authorize deployment, monitoring agents, dashboards, or telemetry infrastructure.

## 2. Approved decisions

### O01 — Linux-native, local-first telemetry

- Use Linux-native sources including systemd unit state, journald, procfs, sysfs, and cgroups as primary sources of system observations.
- Preserve useful operation when disconnected from the internet; cloud services must not be mandatory for basic observability.
- Prefer maintained Debian/Linux integrations over a custom mandatory telemetry stack.
- Permit optional, explicitly configured exporters and remote collectors, subject to security, privacy, and resource controls.
- Document source availability, privilege requirements, measurement semantics, and limitations; not all sources exist on all kernels, devices, or editions.

### O02 — Lightweight, edition-aware metrics

- Collect a minimal baseline of CPU, RAM, swap, disk capacity, disk I/O, network counters, uptime, and systemd service state where available.
- **Server:** prioritize host capacity, storage, critical services, and operational availability.
- **Network:** prioritize interface/link status, throughput, packet errors, routing and connectivity health, and approved DNS/firewall/service indicators.
- **Desktop:** prioritize device health, storage, network connectivity, user-facing performance, and relevant session/service state.
- Make expensive collectors optional and tune sampling frequency and cardinality to host resources.
- Do not assume packet counters alone reveal application health or distinguish all traffic classes.

### O03 — journald-first logging with controlled retention

- Use systemd-journald as the baseline local log source, consistent with the accepted system service architecture.
- Define storage, rate, retention, and size budgets suitable for each edition, including constrained disks and volatile logging where appropriate.
- Preserve event timestamps, service identity, severity, and nonsecret correlation metadata where available.
- Allow optional forwarding/export only through explicitly approved, secured configuration.
- Avoid unlimited independent logs and prevent credentials, API tokens, private keys, or sensitive identifiers from appearing in diagnostics.
- Clarify that journald retention and telemetry time-series retention are distinct concerns.

### O04 — Layered health and readiness classification

- Use **Healthy**, **Degraded**, **Unhealthy**, and **Unknown** as the architecture-level health states.
- Distinguish process existence, systemd active state, application readiness, service functionality, and end-to-end availability.
- Treat **Unknown** as insufficient or stale evidence, not automatically healthy or unhealthy.
- Record the health signal's scope, freshness, source, and applicable dependencies.
- Do not claim end-to-end connectivity based solely on a running network service or local interface status.
- Establish future edition-specific criteria for critical service and system health aggregation.

### O05 — Local alerts first; external notifications optional

- Provide local alert visibility and appropriate edition-specific notification channels without requiring third-party services.
- Define severity, thresholds, hysteresis, cooldown, and deduplication to reduce noise and alert storms.
- Treat loss of telemetry, collector failure, and stale health signals as diagnosable states.
- Make email, webhook, or other remote notification integrations optional and explicitly configured, with secret protection and failure handling.
- Avoid default network transmission of alerts or system details.
- Do not promise delivery during power loss, host shutdown, network isolation, or other unavailable conditions.

### O06 — Privacy-safe diagnostic bundles

- Generate diagnostics locally by default and minimize collected data to the declared troubleshooting purpose.
- Redact or omit passwords, tokens, private keys, Wi-Fi/VPN credentials, personal identifiers, device serials, and sensitive network data.
- Require explicit administrator/user action and appropriate consent before exporting or sharing a diagnostic bundle.
- Include a manifest of sources, time range, collection errors, and redaction limitations where feasible.
- Prevent unprivileged callers from accessing protected system or other-user data.
- Recognize that automated redaction is imperfect; require review before external sharing.

### O07 — Edition-aware dashboard and CLI

- **Server:** CLI as the baseline, with a lightweight optional dashboard.
- **Network:** web dashboard and CLI for operational visibility; remote access must be authenticated, authorized, and network-exposure controlled.
- **Desktop:** KDE-friendly local presentation and CLI, with appropriate integration into desktop notifications.
- Reuse the same conceptual health states and metric semantics across interfaces while allowing edition-specific detail.
- Do not require a heavy GUI or central server for headless deployments.
- Keep any future management actions separate from read-only observation and subject to explicit authorization.

### O08 — Bounded telemetry retention and resource budgets

- Establish finite storage, memory, CPU, sampling, and metric-cardinality budgets based on edition and device capacity.
- Prefer bounded local history, controlled aggregation, and adaptive or configurable sampling for constrained systems.
- Ensure telemetry collection cannot silently exhaust disk, memory, or CPU needed by critical services.
- Define predictable behavior under low-disk, overloaded-host, collector-failure, and telemetry-export-backpressure conditions.
- Distinguish ephemeral operational data from retained audit records and apply relevant privacy/retention controls.
- Exact time-series storage, retention durations, and numerical resource thresholds are deferred.

## 3. Conceptual observability lifecycle

1. **Collect:** read approved Linux-native metrics, systemd state, and journald events using appropriate privileges.
2. **Normalize:** attach consistent units, timestamps, source/freshness information, and edition-specific context.
3. **Evaluate:** assess health, readiness, thresholds, severity, stale evidence, and degraded conditions.
4. **Retain:** store bounded local history and logs under disk and resource budgets.
5. **Present:** expose relevant views through edition-appropriate CLI, web dashboard, or KDE-friendly UI.
6. **Alert:** deliver local alerts and only explicitly configured external notifications.
7. **Diagnose:** assemble minimal, redacted local diagnostics and export only after informed authorization.

This is an architecture workflow, not a running collector, database, alerting service, or dashboard.

## 4. Edition-specific operating policy

| Edition | Primary interface | Baseline signals | Key safeguards |
| --- | --- | --- | --- |
| Server | CLI; dashboard optional | CPU, memory, swap, storage, I/O, uptime, critical systemd units | Low overhead, bounded logs, remote exposure opt-in |
| Network | Web dashboard and CLI | Interface/link counters, routing/connectivity, DNS/firewall and gateway service health | Management authentication, privacy, stale-signal awareness |
| Desktop | KDE-friendly UI and CLI | Device health, resource pressure, storage, connectivity, user-session services | Local-first visibility, user privacy, unobtrusive notifications |

A running process alone does not establish application readiness or end-to-end health.

## 5. Alternatives considered

| Decision | Selected | Rejected as default |
| --- | --- | --- |
| O01 | Linux-native, local-first telemetry | Mandatory cloud monitoring |
| O02 | Lightweight, edition-aware metrics | Collect every metric everywhere |
| O03 | journald-first with controlled retention | Unlimited independent service logs |
| O04 | Layered health and readiness classification | Treat running process as healthy |
| O05 | Local alerts, external optional | Mandatory external alerting |
| O06 | Privacy-safe diagnostic bundles | Automatic full diagnostic uploads |
| O07 | Edition-aware dashboard and CLI | Identical heavy dashboard on every edition |
| O08 | Bounded retention and resource budgets | Unlimited telemetry history |

## 6. Consequences, risks, and mitigations

**Benefits:** usable offline diagnostics, Debian/Linux alignment, lower resource requirements, edition-appropriate operational visibility, predictable health semantics, privacy protection, and optional interoperability with remote monitoring.

**Risks:** inaccurate health signals, misleading network counters, collector privilege escalation, alert storms, telemetry storage exhaustion, log data leaks, accidental public dashboard exposure, diagnostic redaction gaps, and dropped samples under overload.

**Mitigations:** documented signal scope/freshness, least-privilege collectors, health-state uncertainty, hysteresis/cooldown, finite retention and budgets, explicit external export, authenticated dashboard access, redaction, and administrator review of diagnostic bundles.

Telemetry provides evidence for troubleshooting but does not guarantee fault detection, alert delivery, or system recovery.

## 7. Future acceptance criteria — not executed

1. Confirm baseline observability works without internet or external monitoring services.
2. Verify metric source provenance and unit consistency across representative Debian kernel/systemd environments.
3. Measure collection overhead on resource-constrained Server, Network, and Desktop profiles.
4. Validate edition-specific baseline metrics and optional expensive collectors.
5. Confirm journald retention, size, rate limits, and low-disk behavior.
6. Test Healthy/Degraded/Unhealthy/Unknown classification, readiness versus active state, and stale/missing data.
7. Verify alert thresholds, hysteresis, cooldown, deduplication, and degraded notification delivery.
8. Ensure no external telemetry, alert, or diagnostic upload occurs without explicit configuration and authorization.
9. Validate diagnostic redaction, bundle manifests, least-privilege collection, and pre-share review guidance.
10. Test CLI, Network web dashboard, and KDE-friendly presentation against the same conceptual health semantics.
11. Validate dashboard authentication, authorization, and safe network binding/exposure.
12. Exercise bounded storage, sampling, cardinality, and collector backpressure under low disk and host overload.

These are future validation requirements. No collector, agent, exporter, telemetry database, dashboard, alerting engine, diagnostic bundle generator, or runtime test has been implemented or executed.

## 8. Deferred technical design

Specific metrics and units; collection APIs and sampling schedules; cardinality constraints; local time-series storage choice; journald configuration; retention durations; health probe definitions and aggregation; alert rules and delivery integrations; diagnostic redaction schema; collector privilege model; dashboard/CLI interfaces; optional exporter contracts; and resource budget thresholds are deferred to separately approved technical design and implementation.

## 9. Approval and scope

The project owner approved O01=A, O02=A, O03=A, O04=A, O05=A, O06=A, O07=A, and O08=A, then separately approved publication of ADR-0020 Final R1 through feature branch, commit, pull request, squash merge, and verification on `main`.

This ADR inherits ADR-0001 through ADR-0019 without reopening accepted decisions.

**Phase 0 — Architecture & Documentation Only.** No source code, monitoring installation, system/host changes, package or image builds, deployments, runtime tests, or GitHub Actions execution is authorized.
