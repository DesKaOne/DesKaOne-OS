# ADR-0007 — Network Edition Architecture

**Project:** DesKaOne OS  
**Document version:** Final R1  
**Status:** Accepted — architecture/documentation only  
**Decision date:** 2026-10-24  
**Scope:** Network Edition, Shared Security and Management Interfaces  
**Initial architecture:** AMD64  
**Project phase:** Phase 0 — Architecture & Documentation  
**Implementation authorization:** Not granted

## 1. Context

DesKaOne OS Network Edition targets routers, gateways, firewalls and network appliances built on Debian 13 Trixie. It requires persistent network configuration, DNS/DHCP, IPv4/IPv6 routing, firewall/NAT, optional VPN, safe remote administration and reliable recovery from configuration errors.

The edition must integrate with the shared Debian base and approved ADR-0001 through ADR-0006. The network control plane must avoid unbounded root command execution and must not expose management services on public interfaces by default.

## 2. Decisions

### D1 — systemd-networkd for interface management

Adopt **systemd-networkd** as the primary manager for network interfaces, addressing and supported VLAN/bridge configurations. Planned capabilities include WAN/LAN assignment, static IPv4/IPv6, DHCP client, VLAN, bridge, routes and persistent configuration.

- Define clear ownership of interfaces to prevent conflicts with alternative managers.
- Support safe boot-time loading and consistent naming or explicit device matching.
- Validate interface existence, dependencies and address/subnet conflicts before activation.
- Do not assume every physical NIC, wireless interface or hardware offload feature is supported without testing.
- Avoid taking over interfaces used for existing management until recovery and confirmation are established.

### D2 — dnsmasq for DNS and DHCP

Adopt **dnsmasq** as the initial DNS forwarder and DHCP server for approved LAN interfaces.

- Bind DNS/DHCP services only to configured interfaces and addresses; do not accidentally expose recursive DNS or DHCP to WAN.
- Support configurable upstream resolvers, DHCP scopes, reservations and lease visibility.
- Validate pool boundaries, overlaps, gateway/DNS options and conflicting server processes.
- Define how dnsmasq interacts with systemd-resolved or other local resolver components to prevent port and configuration conflicts.
- IPv6 router advertisements and DHCPv6 requirements must be specified and validated before advertising full IPv6 LAN support.
- Treat advanced authoritative DNS and enterprise DHCP requirements as possible future modules.

### D3 — Native Linux routing, policy routing and nftables

Adopt Linux kernel routing and **nftables** for packet filtering, NAT and approved policy-routing behavior.

- Keep local input, output and forwarded traffic policies distinct.
- Define explicit WAN/LAN trust zones, forwarding rules and NAT behavior.
- Provide controlled IPv4 and IPv6 support; do not assume IPv4 NAT rules apply to IPv6.
- Validate routing tables, rules, default routes and potential asymmetric paths.
- No unrestricted WAN-to-LAN forwarding, open proxy or public management access by default.
- Coordinate routing, interface and firewall updates as one recoverable change where dependencies require it.
- Dynamic routing protocols and FRRouting are not part of the initial foundation; require later justification.

### D4 — WireGuard-first VPN

Adopt **WireGuard** as the primary VPN foundation, with **OpenVPN** as an optional future integration.

- VPN enablement and exposure require explicit administrator action.
- Protect private keys and configuration; never log or display raw secrets unnecessarily.
- Validate tunnel addressing, allowed IPs, routes, DNS and firewall dependencies.
- Support safe rotation/recovery procedures for credentials and tunnel changes.
- No claim of complete multi-VPN or site-to-site functionality until separately designed and tested.
- IPsec and additional VPN engines are deferred.

### D5 — Go controller, HTML/HTMX dashboard and CLI

Adopt a hybrid management plane:

- A **Go network controller** owns validated configuration transactions and exposes narrowly scoped management operations.
- A server-rendered **HTML/HTMX dashboard** provides administration, status and audit visibility.
- A **CLI** supports local/headless and rescue administration.
- Dashboard and CLI use the same underlying validated operations and configuration model.
- Apply authentication, RBAC, CSRF protections where applicable, secure sessions, least privilege, request validation and audit logging.
- Never expose an unrestricted root shell or generic privileged command runner through the dashboard.
- Privileged operations must use a constrained, auditable execution boundary.
- Bind management endpoints to approved interfaces/networks; no WAN/public exposure by default.
- API shape, auth bootstrap, service boundaries and packaging remain future technical-design decisions.

### D6 — Transactional safe-apply and rollback

Network changes affecting management reachability must be **transactional**:

1. Accept a candidate configuration.
2. Validate syntax, schema, dependencies, interface and address consistency, and applicable service constraints.
3. Save a known-good configuration and recovery metadata.
4. Apply the candidate in a bounded confirmation window.
5. Require explicit confirmation through an authorized path.
6. Commit confirmed changes; otherwise automatically revert to known-good state.
7. Audit candidate creation, application, confirmation, failure and rollback.

- Coordinate systemd-networkd, nftables, dnsmasq and VPN changes when relevant.
- Prevent concurrent conflicting transactions.
- Preserve local CLI/rescue recovery when remote connectivity is lost.
- Consider process crashes, host reboots, power loss and partial apply failures; document guarantees rather than assuming atomicity across independent daemons.
- Timeout values, persistence format, watchdog and rollback mechanics remain open technical decisions.
- Confirmation from a remote browser alone is not proof of general gateway connectivity; verification strategy must consider management reachability and forwarding health.

## 3. Initial scope boundaries

The future Network Edition MVP is expected to prioritize:

- Wired WAN/LAN interfaces, static addressing and DHCP client.
- Basic bridge/VLAN configuration on validated hardware.
- dnsmasq DNS forwarding and DHCP service.
- IPv4 routing, forwarding and NAT.
- Explicit nftables firewall policy.
- WireGuard baseline integration.
- Dashboard/CLI administration, status and audit.
- Safe-apply, rollback and local recovery.

IPv6 feature completeness, advanced DHCPv6/RA, multi-WAN failover, traffic shaping/QoS, captive portal, wireless AP management, dynamic routing, IDS/IPS, OpenVPN integration and enterprise policy features require separate scope and verification. No feature is declared implemented by this ADR.

## 4. Security and operational principles

- Preserve ADR-0006 non-root admin, least privilege, AppArmor, security-event auditing and safeguarded updates.
- Use no shared default passwords, hardcoded private keys or unrestricted remote management.
- Apply default-deny unsolicited inbound policies, while explicitly designing forwarded traffic rather than treating it as host inbound traffic.
- Avoid unintended DNS amplification, DHCP leakage or open forwarding.
- Provide recoverable local access and clear operator-visible errors.
- Minimize unnecessary writes and rotate logs consistent with ADR-0003.
- Support controlled configuration migrations and versioned schema evolution.

## 5. Alternatives considered

| Decision | Selected | Alternatives not selected as the initial foundation |
| --- | --- | --- |
| Interface management | systemd-networkd | NetworkManager |
| DNS/DHCP | dnsmasq | Kea DHCP + Unbound |
| Routing/firewall | Linux routing, policy routing and nftables | FRRouting as primary engine |
| VPN | WireGuard-first, optional OpenVPN | WireGuard/OpenVPN/IPsec all required from MVP |
| Management | Go + HTML/HTMX + CLI | Separate API-first frontend |
| Recovery | Transactional safe-apply with timeout and rollback | Immediate apply with manual-only recovery |

## 6. Consequences

**Benefits:** Debian-native networking, reduced service complexity, a consistent dashboard/CLI control plane, secure network-service exposure, WireGuard-first VPN, and recoverability for remote configuration changes.

**Risks:** Interface manager conflicts; dnsmasq/resolver conflicts; NAT and policy-routing complexity; IPv6 differences; management lockout; cross-daemon partial transactions; privilege boundary bugs; VPN key exposure; service restart and power-loss recovery challenges.

## 7. Future verification requirements

These are **future acceptance criteria, not completed tests**:

1. Debian 13 compatibility and reproducible package selection.
2. Correct WAN/LAN interface mapping and persistence.
3. DHCP client and static IPv4/IPv6 configuration.
4. Validated bridge and VLAN behavior.
5. No conflicting interface ownership.
6. dnsmasq DNS binding restricted to approved interfaces.
7. DHCP scopes, reservations and conflict validation.
8. No accidental WAN DHCP/DNS service.
9. IPv4 routing, forwarding and NAT.
10. Explicit IPv6 routing/firewall behavior for supported features.
11. nftables input/output/forward policies and persistence.
12. Policy routing and route conflict validation.
13. No default public management exposure.
14. WireGuard tunnel, routing and key handling.
15. Dashboard authentication, authorization, CSRF and session protections.
16. CLI/dashboard configuration consistency.
17. No unrestricted privileged command execution.
18. Safe-apply confirmation and timeout rollback.
19. Recovery after management disconnect, partial failure, service crash and reboot.
20. Audit trail and known-good configuration recovery.

## 8. Open decisions

- Detailed network configuration schema and source of truth.
- Interface discovery, stable naming and hotplug policy.
- systemd-resolved/dnsmasq integration.
- IPv6 RA and DHCPv6 strategy.
- Routing tables, policy rules, NAT and firewall policy templates.
- WireGuard key lifecycle and secret storage.
- Controller privilege separation and service boundaries.
- Dashboard authentication bootstrap, roles and API contracts.
- Transaction timeout, locking, rollback persistence and failure semantics.
- Monitoring metrics, backup/restore and upgrade migration.
- Hardware/virtualization compatibility and minimum resource targets.

## 9. Phase restrictions

**Phase 0 — Architecture & Documentation Only.** This ADR does **not** authorize network daemon configuration, Go code, dashboard or CLI implementation, firewall/routing changes, DNS/DHCP or VPN setup, package changes, build images, CI/CD, host modifications or Phase 1. All implementation requires separate explicit approval.

## 10. Approval record

On **2026-10-24**, the project owner selected systemd-networkd, dnsmasq, native Linux routing/nftables/policy routing, WireGuard-first with optional OpenVPN, Go + HTML/HTMX + CLI, and transactional safe-apply/rollback. **Final Draft R1 was subsequently approved for documentation publication.**
