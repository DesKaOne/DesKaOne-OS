# DesKaOne OS — Bootstrap 02 System Foundation R1

Source-only candidate on Debian 13 Trixie AMD64, building on Bootstrap 01.

## Included
- Conservative sysctl defaults (no IP forwarding in the shared base).
- A wired-interface DHCP client networkd profile; no router configuration.
- Foundation metadata declaring accepted network components.
- Candidate packages for systemd-resolved, nftables, WireGuard and SSH client.

## Important integration boundaries
- The networkd profile is **not activated** by this source commit. Debian live-build inclusion alone does not prove service enablement or interface ownership.
- dnsmasq was included in Bootstrap 01's provisional package list. Its server role and resolver coexistence are not configured here.
- Server/Network/Desktop require separate edition-specific service and network ownership policies. Desktop NetworkManager must not compete with networkd.
- No SSH server, firewall rules, forwarding, NAT, VPN peers, credentials, secrets, or public services are enabled here.
- The sysctl defaults must be overridden explicitly by a future authorized Network edition router profile.
- The `systemd-resolved` candidate may need removal or edition-specific selection after validating dnsmasq/resolver integration.

## Validation
This commit only provides source files. No package installation, ISO build, VM boot, networking, security, or runtime validation has been performed.

## Next
Define edition-specific activation and resolver ownership, then validate package resolution and service behavior in an approved sandbox before any runtime claims.
