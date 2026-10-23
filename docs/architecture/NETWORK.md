# Network Edition — Design Specification

**Status:** Design only. Implementation not authorized.

## Purpose
Router, firewall, gateway, VPN and optional proxy appliance.

## Planned baseline
iproute2, nftables/NAT, WireGuard, DNS/DHCP backend, versioned config, Go + HTMX dashboard and CLI.

## Management architecture
Both interfaces call the same validated management operations. Unprivileged web service delegates narrowly authorized operations to a privileged executor. Authenticate sessions, protect CSRF, rate limit, audit changes and bind administration to configured interfaces.

## Safety transaction
Validate → snapshot known-good → apply candidate → health check → require confirmation → rollback automatically on timeout/failure. Preserve a recovery channel and test across reboot/service restart.

## Integration boundaries
ProxyHub, Proxy Rotator and Control Center are optional; base routing must work without them. Never enable an open proxy or public management interface by default.

## Acceptance gates
Routing/NAT, firewall persistence, VPN, web/CLI parity, authentication, rollback under connectivity loss, recovery and throughput/memory benchmarks.

## Open decisions
DNS/DHCP implementation, auth/session design, config persistence, rollback executor and management-plane interface model.
