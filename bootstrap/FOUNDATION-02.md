# DesKaOne OS — Bootstrap 02 System Foundation R1

Source-only candidate on Debian 13 Trixie AMD64, building on Bootstrap 01.

## Included
- Conservative sysctl defaults (no IP forwarding in the shared base).
- An **inactive example** wired-interface DHCP client networkd profile at `examples/networkd/10-deskaone-wired.network`; no router configuration.
- Foundation metadata declaring accepted network components.
- Candidate shared-base packages for nftables, WireGuard and SSH client. `systemd-resolved` is staged only as an inactive example under `examples/package-lists/`.

## Important integration boundaries
- The networkd example is deliberately **outside** `config/includes.chroot`, so live-build does not install this profile into `/etc/systemd/network`. Future edition integration must select and install it explicitly after interface-ownership review.
- dnsmasq was included in Bootstrap 01's provisional package list. Its server role and resolver coexistence are not configured here.
- Server/Network/Desktop require separate edition-specific service and network ownership policies. Desktop NetworkManager must not compete with networkd.
- No SSH server, firewall rules, NAT, VPN peers, credentials, secrets, or public services are enabled here. The shared sysctl file explicitly disables IP forwarding if included in a built image.
- The sysctl defaults must be overridden explicitly by a future authorized Network edition router profile.
- `systemd-resolved` is **not** in the active live-build package list. The inactive example must not be promoted until dnsmasq/resolver integration, port binding and `/etc/resolv.conf` ownership are validated.

## Validation
This commit only provides source files. No package installation, ISO build, VM boot, networking, security, or runtime validation has been performed.

## Next
Define edition-specific activation and resolver ownership, then validate package resolution and service behavior in an approved sandbox before any runtime claims.

## Source-level checks (not run)
From the `bootstrap` directory, run `bash scripts/validate-source.sh` for Bootstrap 01 syntax and file assertions. Confirm `systemd-resolved` does not appear in any active `config/package-lists/*.list.chroot` file and confirm no networkd `.network` file is present in `config/includes.chroot/etc/systemd/network/`. These are source-level checks, not a substitute for runtime tests.
