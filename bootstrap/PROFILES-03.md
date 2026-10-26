# DesKaOne OS — Bootstrap 03 Edition Profiles R1

This is a **source-only proposal**, based on Debian 13 Trixie AMD64 and the accepted Desktop/Server architectural choices. It does not install or activate edition profiles.

## Directory isolation
All proposed edition packages and metadata live under `bootstrap/profiles/`, **outside** `bootstrap/config/package-lists/` and `bootstrap/config/includes.chroot/`. Thus the existing live-build scaffold does not automatically include them. An explicit, separately reviewed edition-selection mechanism is required.

## Desktop candidate
- Wayland desktop session, SDDM display manager, minimal desktop package set, APT + Flatpak.
- NetworkManager would own Desktop network interfaces. Do not install or activate the staged networkd DHCP example alongside it for the same interfaces.
- Btrfs recovery is an architectural target, not implemented here.
- Package availability, display stack dependencies, SDDM compatibility and session boot remain untested.

## Server candidate
- systemd-networkd as interface owner; dnsmasq for scoped DNS/DHCP service after resolver ownership is defined.
- Native nftables firewall and WireGuard candidates; no rules, keys, peers, forwarding or remote access are enabled.
- Hybrid management and transactional recovery are future integrations, not delivered by this scaffold.
- SSH server is a package candidate only and is **not** selected into the active base package lists.

## Explicit safety boundaries
- No service enablement, edition selection, default credentials, unattended SSH exposure, networking changes, firewall policies, Btrfs partitioning or recovery automation.
- No GitHub Actions, host execution, ISO build or VM boot.
- These profiles are examples, not runnable editions. The Desktop and Server package sets are provisional.

## Next review gates
1. Confirm candidate package availability and correct Debian 13 naming in an approved environment.
2. Design edition selection with single interface owner and DNS resolver owner per profile.
3. Specify edition activation and test strategy before promoting any file into active live-build directories.

## Manual source validation (not executed)
From `bootstrap/`, run `bash scripts/validate-profiles-source.sh`. This checks Bootstrap 01/02 source guards, profile metadata, required package candidates, and that Desktop/Server-only packages and edition selection are not active in the shared live-build configuration. It does not resolve Debian packages, enable services, build an ISO, or test boot behavior.
