# ADR-0018 — Network Configuration & Connectivity Architecture

**Project:** DesKaOne OS  
**Version:** Final R1  
**Status:** Accepted — architecture/documentation only  
**Decision date:** 2026-10-25  
**Scope:** Network managers, IPv4/IPv6, DNS/DHCP, firewall, routing/gateway, safe changes, remote administration, and diagnostics across Server, Network, and Desktop editions  
**Implementation authorization:** Not granted

## 1. Context and objectives

DesKaOne OS is a Debian Stable-based distribution with Server, Network, and Desktop editions. Network configuration must accommodate headless servers, gateways with multiple interfaces, and mobile desktops without introducing a custom network stack. A remotely applied change to addresses, routes, firewall rules, or DNS can interrupt administrative access. Network services and gateway capabilities must not activate unexpectedly.

This ADR establishes edition-aware network-management ownership, dual-stack support, modular services, native Linux firewall/routing, safe configuration workflows, and local-first diagnostics. It inherits ADR-0001 through ADR-0017 without reopening accepted decisions.

## 2. Approved decisions

### N01 — Edition-specific Linux network managers

- **Server and Network editions:** use systemd-networkd as the default interface configuration manager.
- **Desktop edition:** use NetworkManager as the default, integrating with KDE Plasma's network UI.
- Ensure a given interface has a single authoritative network manager; do not allow systemd-networkd and NetworkManager to compete for the same interface.
- Define clear ownership for resolver configuration and interactions with systemd-resolved or equivalent approved resolver integration.
- Do not overwrite administrator-owned network configuration or silently migrate ownership between managers.
- Exact file layouts, handoff/migration tooling, and service defaults are deferred to technical design.

### N02 — First-class IPv4/IPv6 dual-stack connectivity

- Support IPv4 and IPv6 as first-class network protocols across editions.
- Support DHCPv4, static IPv4, static IPv6, IPv6 SLAAC, and DHCPv6 as appropriate to interface role and network capability.
- Do not disable IPv6 globally by default; allow documented administrator policies for specific environments.
- Avoid assuming DHCPv6 provides the default IPv6 gateway or that all IPv6 networks use identical address assignment.
- Account for route preference, address lifetimes, DNS resolution, and security implications of router advertisements.
- Validate dual-stack behavior without assuming IPv4 and IPv6 connectivity will always succeed simultaneously.

### N03 — Modular resolver and DHCP roles

- Distinguish local stub/system resolver, upstream DNS selection, DHCP clients, and optional DNS/DHCP server workloads.
- Configure resolver integration consistently with the selected edition network manager; prevent competing components from overwriting resolver state.
- Do not start DHCP or authoritative/forwarding DNS servers automatically on every installation.
- Make DHCP server, DNS forwarding, and related Network Edition services explicitly enabled and scoped to administrator-selected interfaces.
- Guard against rogue DHCP, DNS conflicts, unwanted binding to public interfaces, and accidental exposure.
- Keep exact server packages and service configurations for later technical design.

### N04 — nftables-native firewall foundation

- Use the Linux nftables framework and edition-specific baseline policy, managed through established Debian/Linux mechanisms.
- Maintain persistent, reviewable, administrator-controlled rules and clear ownership between native nftables, approved frontends, and service-managed rules.
- Avoid simultaneous unmanaged firewall controllers modifying the same chains/tables.
- Preserve essential management connectivity when changing remote firewall policy and provide a recovery plan.
- Treat IPv4 and IPv6 firewall behavior explicitly; do not accidentally leave IPv6 unfiltered.
- Do not assume a generic default policy is appropriate for every gateway, desktop, or exposed server workload.

### N05 — Linux-native routing and opt-in gateway roles

- Use Linux kernel routing, static routes, policy routing, and supported native tooling rather than a custom routing stack.
- Enable IP forwarding, NAT, gateway mode, routing policy changes, and related services only through approved explicit configuration.
- Do not turn a newly installed device into a router or DHCP server without administrator intent.
- Account for multi-NIC interfaces, route precedence, IPv4/IPv6 differences, and possible interactions with VPN/tunnel interfaces.
- Keep gateway/routing changes reversible where feasible and document cases where remote recovery cannot be guaranteed.
- Advanced routing protocols, overlays, VPN integration, and performance optimizations require separate technical design or approval.

### N06 — Safe network configuration application

- Treat network changes as a **transactional-style** workflow: prepare, validate, stage where possible, apply under safeguards, verify, then retain or attempt recovery.
- Preflight syntax, interface ownership, address and route conflicts, DNS dependencies, firewall implications, and management access risk.
- Preserve prior configuration and establish an appropriate local/console or out-of-band recovery path before high-risk remote changes.
- Where supported, use bounded confirmation or rollback mechanisms that avoid leaving an unconfirmed change permanently active.
- Do not claim universal atomic network transactions or guaranteed rollback across link loss, kernel state, physical faults, or independent service managers.
- Record failed or degraded changes clearly and avoid silently claiming success.

### N07 — Remote management connectivity safeguards

- Identify administrator management paths and evaluate whether proposed changes could disrupt interface addresses, routes, DNS, SSH or dashboard access, firewall permissions, and gateway reachability.
- Apply stricter safeguards for remote Server and Network administration, especially for multi-interface gateways.
- Prefer explicit confirmation for disruptive changes and require a documented rescue/console/out-of-band access strategy when practical.
- Never treat a successful local network service restart alone as proof that a remote administrator can reconnect.
- Health checks must distinguish local interface readiness from end-to-end management reachability.
- Do not promise continuous connections or zero lockout under every failure scenario.

### N08 — Declarative profiles and privacy-safe diagnostics

- Represent intended network configuration as versionable, validated profiles with clear ownership and administrator override boundaries.
- Validate incompatible interface ownership, conflicting address/routing definitions, and unexpected firewall/DNS service interactions before applying profiles.
- Provide local-first diagnostics for interface state, addresses, routes, resolver behavior, DHCP state, firewall status, and connectivity tests.
- Redact Wi-Fi passwords, VPN credentials, authentication tokens, private keys, and other secrets from reports and audit records.
- Do not automatically upload network inventories, identifiers, or diagnostic bundles.
- Preserve enough nonsecret metadata to understand configuration revisions, errors, and recovery actions.

## 3. Conceptual network change lifecycle

1. **Prepare:** load the administrator-approved declarative profile and determine authoritative manager ownership per interface.
2. **Preflight:** validate syntax, addresses, routes, resolver and DHCP roles, firewall rules, dependencies, and management reachability risk.
3. **Protect:** save previous state/configuration and confirm feasible recovery or bounded confirmation where appropriate.
4. **Apply:** enact approved changes through systemd-networkd, NetworkManager, nftables, and native Linux routing tools.
5. **Verify:** check interfaces, addressing, routing, DNS, firewall, and edition-relevant end-to-end management connectivity.
6. **Commit or recover:** retain healthy changes or attempt restoration and report any residual failure.
7. **Record:** retain redacted diagnostics, audit history, and unresolved administrator actions.

This lifecycle is an architectural policy, not an implemented atomic network transaction engine.

## 4. Edition-specific operating policies

| Edition | Network manager | Default priorities | Optional roles |
| --- | --- | --- | --- |
| Server | systemd-networkd | Stable wired/static/DHCP connectivity, dual stack, nftables, SSH/remote-management safety | Service-specific routing, additional network services |
| Network | systemd-networkd | Multi-NIC ownership, routing/firewall integrity, remote gateway management, dual stack | Explicitly enabled forwarding, NAT, DHCP/DNS services, advanced routing |
| Desktop | NetworkManager | Ethernet/Wi-Fi mobility, KDE Plasma integration, dual stack, user-controlled changes | VPN/tunnels and approved local services |

A single interface must not be actively controlled by two competing network managers.

## 5. Alternatives considered

| Decision | Selected | Rejected as default |
| --- | --- | --- |
| N01 | Edition-specific Linux managers | One manager for every edition |
| N02 | First-class IPv4/IPv6 | IPv4-first with limited IPv6 |
| N03 | Modular resolver and DHCP roles | DNS/DHCP servers bundled and active everywhere |
| N04 | nftables-native firewall | Custom firewall engine |
| N05 | Linux-native routing, gateway opt-in | Gateway capabilities enabled by default |
| N06 | Safe apply with validation and recovery | Immediate unsafeguarded apply |
| N07 | Management-aware connectivity protection | Treat all network changes equally |
| N08 | Declarative profiles and privacy-safe diagnostics | Ad-hoc untracked configuration only |

## 6. Consequences, risks, and mitigations

**Benefits:** Native Debian/Linux integration, desktop usability, predictable headless/gateway behavior, dual-stack capability, safer remote changes, administrator control, and clearer diagnostics.

**Risks:** Manager conflicts, resolver overwrite, rogue DHCP, accidental forwarding/NAT, IPv6 firewall gaps, SSH lockout, DNS outages, asymmetric routing, interface renaming, and incomplete rollback after remote disconnection.

**Mitigations:** Single-manager ownership, service opt-in, nftables policy controls, validated profiles, explicit management-path checks, prior-state preservation, local/out-of-band recovery, redacted audit trails, and transparent degraded-state reporting.

Safe-apply procedures reduce risk but cannot guarantee recovery from physical link failures, missing out-of-band access, kernel crashes, or unrelated infrastructure outages.

## 7. Future acceptance criteria — not executed

1. Confirm Server and Network use systemd-networkd and Desktop uses NetworkManager without concurrent ownership of the same interface.
2. Validate DHCPv4, static IPv4, static IPv6, SLAAC, DHCPv6, and representative mixed dual-stack environments.
3. Verify resolver configuration remains consistent and does not oscillate between competing network services.
4. Ensure DHCP/DNS server roles are disabled unless explicitly configured and bound only to approved interfaces.
5. Validate nftables persistence, IPv4/IPv6 coverage, service integration, and management access safeguards.
6. Verify routing, NAT, forwarding, and gateway roles require explicit administrator configuration.
7. Exercise malformed configuration, address conflicts, route loss, firewall lockout risk, and failed DNS changes during preflight.
8. Test bounded confirmation or best-effort recovery for remotely applied changes where supported; document irrecoverable scenarios.
9. Confirm Network Edition multi-NIC and Server remote-management checks evaluate end-to-end reachability, not only local interface state.
10. Validate declarative profile conflict detection, administrator override preservation, and revision tracking.
11. Verify local diagnostic reports redact Wi-Fi/VPN credentials, private keys, tokens, and other secrets.
12. Ensure degraded or partially applied changes produce actionable status and recovery instructions rather than false success.

These are future validation requirements. No network manager, firewall policy, routing configuration, safe-apply service, or runtime test has been implemented or executed.

## 8. Deferred technical design

Exact systemd-networkd and NetworkManager profile schemas; resolver integration details; DHCP/DNS service package selection; nftables rule ownership and base chains; IPv6 RA and DHCPv6 policies; NAT and forwarding profiles; interface naming conventions; safe-apply confirmation timeout and rollback mechanics; remote connectivity probes; VPN/overlay interactions; audit data schema; diagnostic command/UI surfaces; and recovery runbooks are deferred to separately approved technical design and implementation.

## 9. Approval and scope

The project owner approved N01=A, N02=A, N03=A, N04=A, N05=A, N06=A, N07=A, and N08=A, then separately approved publication of ADR-0018 Final R1 through feature branch, commit, pull request, squash merge, and verification on `main`.

This ADR inherits ADR-0001 through ADR-0017 without reopening accepted decisions.

**Phase 0 — Architecture & Documentation Only.** No source code, networking configuration, firewall/routing changes, host changes, package/image builds, deployments, runtime tests, or GitHub Actions execution is authorized.
