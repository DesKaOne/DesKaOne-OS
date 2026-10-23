# DesKaOne OS

**One Core. Three Editions. One Ecosystem.**

> **Status: architecture and documentation only.** No installable images, Debian packages, or production releases exist yet. Do not use this project as an operating system today.

DesKaOne OS is a community-oriented Debian Stable derivative planned in three editions:

| Edition | Purpose | Planned baseline |
| --- | --- | --- |
| **Server** | VPS, bare metal, homelabs | Headless, OpenSSH, nftables, systemd-networkd |
| **Network** | Routers, firewalls, VPNs and proxy gateways | Web dashboard + CLI, nftables, WireGuard, safe configuration rollback |
| **Desktop** | Everyday use and development | KDE Plasma, SDDM, Wayland, NetworkManager, PipeWire |

The first supported architecture will be **AMD64**. **ARM64** is a later milestone, with device-specific support explicitly tested.

## Project principles

- Debian Stable first; retain upstream package and security-update compatibility.
- APT/dpkg and systemd; no replacement package manager or custom kernel for the MVP.
- One monorepo, modular edition packages and optional ecosystem integrations.
- Secure defaults, signed release artifacts and reproducible builds.
- Clear phase approvals: documentation approval does **not** authorize implementation.

## Documentation

- [System architecture](docs/architecture/ARCHITECTURE.md)
- [Roadmap](ROADMAP.md)
- [Agent and contribution safeguards](AGENTS.md)
- [Server edition](docs/architecture/SERVER.md)
- [Network edition](docs/architecture/NETWORK.md)
- [Desktop edition](docs/architecture/DESKTOP.md)
- [Security model](docs/security/SECURITY-MODEL.md)
- [Update policy](docs/security/UPDATE-POLICY.md)
- [Package strategy](docs/packages/PACKAGE-STRATEGY.md)
- [Build and release strategy](docs/build/BUILD-STRATEGY.md)
- [Debian-base decision](docs/decisions/ADR-0001-DEBIAN-BASE.md)

## Contributing

We welcome global contributors to discuss design, review security assumptions, improve documentation and propose Architecture Decision Records. **Do not submit implementation work as an approved roadmap phase unless maintainers explicitly authorize it.**

See [CONTRIBUTING.md](CONTRIBUTING.md), [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md), and [SECURITY.md](SECURITY.md). For questions, use GitHub Issues.

## Licensing

Original DesKaOne-authored material in this repository is offered under the [MIT License](LICENSE), unless a file specifies otherwise. Debian, Linux, KDE and other third-party components retain their own licenses. No third-party package source is included in this documentation checkpoint.

DesKaOne OS is an independent project, not an official Debian project or product.
