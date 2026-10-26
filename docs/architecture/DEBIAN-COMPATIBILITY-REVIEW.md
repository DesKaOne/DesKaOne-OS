# Debian Stable Compatibility — Documentation Review

**Status:** Architecture research only; implementation not authorized. · **Reviewed:** 2026-10-24

## Scope and accepted baseline

This review covers package management, systemd, upstream security maintenance and edition dependencies in the [architecture](ARCHITECTURE.md) and [package strategy](../packages/PACKAGE-STRATEGY.md). Verified Debian facts below describe upstream documentation, not tested DesKaOne behavior. Proposed mitigations are review recommendations, not new architecture decisions or implementation approval.

The accepted baseline is **Debian 13 Trixie**, AMD64 first, retaining APT/dpkg, systemd and official Debian kernels ([ADR-0001, Decisions D1–D2 and D5](../decisions/ADR-0001-DEBIAN-BASE.md)). The installer framework and filesystem defaults are decided: Debian Installer for Server/Network, KDE Live + Calamares for Desktop, ext4 for Server/Network and Btrfs for Desktop ([ADR-0002, Decisions D1](../decisions/ADR-0002-INSTALLER-BOOT.md); [ADR-0003, Decisions D1](../decisions/ADR-0003-STORAGE-RECOVERY.md)). Integration and recovery validation remain future work.

The accepted package model is official Debian sources plus a signed DesKaOne overlay with **Stable/Testing/Unstable** channels; these do not select Debian Testing/Unstable ([ADR-0005, Decisions D1–D2](../decisions/ADR-0005-PACKAGE-REPOSITORY.md)). Package names in the strategy remain illustrative; dependency manifests are not approved by this review.

## Verified Debian facts

Sources were fetched and checked on the review date. Package listings establish upstream availability and declared relationships, not a validated edition manifest.

| Area | Verified fact and authoritative reference |
| --- | --- |
| Dependency semantics | Debian Policy distinguishes required `Depends`, strong but non-absolute `Recommends`, and optional `Suggests`; it separately defines `Breaks`, `Conflicts` and file takeover through `Replaces` ([Policy §§7.2–7.6](https://www.debian.org/doc/debian-policy/ch-relationships.html)). |
| Configuration ownership | Local configuration changes must survive upgrades. For a shared configuration file, Policy requires an owning package; other packages must not modify another package's conffile directly ([Policy §§10.7.3–10.7.4](https://www.debian.org/doc/debian-policy/ch-files.html)). |
| systemd integration | Debian's default service manager is systemd; Policy describes service units and dependency/ordering information ([Policy §9.3.1](https://www.debian.org/doc/debian-policy/ch-opersys.html)). Debian's `dh_installsystemd` generates maintainer-script actions for service enablement, startup, shutdown and restart during package lifecycle operations ([Trixie manual, Description](https://manpages.debian.org/trixie/debhelper/dh_installsystemd.1.en.html)). |
| Repository trust | APT authenticates signed repository metadata and the checksum chain to packages; trusting an archive is not a review of package safety. `Signed-By` can associate a source with its key ([Trixie apt-secure, User Configuration and Signed Repositories](https://manpages.debian.org/trixie/apt/apt-secure.8.en.html)). |
| Security maintenance | Debian backports security fixes into Stable package versions; upstream version age alone does not establish vulnerability. Its Security Team does not support `contrib`, `non-free` and `non-free-firmware` in the same way as the distribution, though supplied fixes may be processed ([Security FAQ, version numbers and component coverage](https://www.debian.org/security/faq.en.html)). |
| Server and Network dependencies | Trixie lists [openssh-server](https://packages.debian.org/trixie/openssh-server) as providing `sshd`, and [dnsmasq](https://packages.debian.org/trixie/dnsmasq) as a DNS/DHCP system daemon depending on `dnsmasq-base`. This verifies these components' availability, not service exposure or compatibility of a combined configuration. |
| Desktop dependency breadth | Trixie's `task-kde-desktop` depends on `kde-standard`, `sddm` and `task-desktop`, and recommends applications including LibreOffice components ([package relationships](https://packages.debian.org/trixie/task-kde-desktop)). |
| Major upgrades | Debian's Trixie upgrade notes recommend backups and recovery preparation, warn that unofficial packages may be removed for conflicting dependencies, and discuss pinning and package-state checks ([Release Notes §§4.1–4.2](https://www.debian.org/releases/trixie/release-notes/upgrading.en.html)). These notes cover Bookworm → Trixie; they do not validate a future DesKaOne major upgrade. |

## Risks and proposed mitigations

The following are compatibility risks inferred from those facts and the accepted design. Mitigations are **proposals for later authorized design and validation**, not completed controls.

| Risk | Proposed mitigation and decision boundary |
| --- | --- |
| A metapackage pulls optional workloads or Desktop services into the shared core; conflicting relationships remove upstream functionality. | Review dependency closures per edition, including recommendations, installation and removal. Separate required edition functionality from optional bundles; review `Breaks`/`Conflicts`/`Replaces` explicitly. Keep exact manifests open under ADR-0005 D1 and ADR-0008 §6. |
| Branding or configuration packages overwrite administrator settings or compete for file ownership. | Document an owner and migration path for shared files; review install, upgrade, remove, purge and interrupted configuration behavior against Policy §10.7. Preserve accepted configuration ownership intent in the package strategy. |
| Service installation or upgrades start/restart daemons unexpectedly, exposing services or interrupting SSH/gateway access. | Review unit lifecycle, ordering and edition exposure together; plan recovery and interrupted-upgrade checks. Preserve ADR-0006 D3's edition-dependent SSH enablement and ADR-0007 D6's safe-apply requirement. Exact unit and restart policies remain technical design. |
| Overlay packages override Debian fixes, or restrictive priorities block security updates. | Validate package origins, dependency resolution, channel transitions and security-update eligibility before promotion. Retain ADR-0005 D4–D6's scoped trust and protected selection; signing alone cannot demonstrate selection safety. Pin values and scheduling remain open. |
| Debian maintenance is assumed to cover DesKaOne changes, optional firmware/drivers or external application channels. | Assign maintenance ownership and advisory tracking to the overlay and optional components; record source and support limits. Check Debian advisories/changelogs rather than upstream version numbers alone. Preserve optional firmware and Flatpak choices (ADR-0001 D4; ADR-0008 D4–D5); support lifecycle remains open under ADR-0006 §6. |
| Edition dependencies undermine the selected network or Desktop design. | For Server, review headless dependency closure and SSH recovery. For Network, validate interface ownership and dnsmasq/resolver interaction without choosing the unresolved resolver integration (ADR-0007 D1–D2, §8). For Desktop, review broad task dependencies against minimal apps and optional bundles, and validate Wayland/X11 combinations rather than inferring support from package presence (ADR-0008 D1–D3, §6). |
| Upgrade or downgrade leaves package, service and persistent data state inconsistent. | Plan dependency/migration checks across editions, backup/restore drills and recovery from partial package operations. Review retained overlay versions for compatible dependencies; retain ADR-0005 D7's warning that downgrades are not guaranteed rollbacks. Desktop snapshots do not replace backups (ADR-0003 D6). |

## Upgrade, maintenance and open decisions

Automatic security updates with safeguards, manual major upgrades and no uncontrolled automatic reboots are accepted policy ([ADR-0001, Decisions D3](../decisions/ADR-0001-DEBIAN-BASE.md); [ADR-0005, Decisions D5](../decisions/ADR-0005-PACKAGE-REPOSITORY.md)). **Proposed verification:** check successful and failed security updates, pending restarts, maintenance visibility and connectivity recovery for each edition. For a future major release, consult that release's Debian notes and review overlay compatibility and migrations before changing the accepted baseline.

Open technical decisions remain in the accepted ADRs:

- [ADR-0005, §6 Open decisions](../decisions/ADR-0005-PACKAGE-REPOSITORY.md): suite/component names, signing lifecycle, APT preferences, update eligibility/scheduling, promotion gates and package retention/recovery.
- [ADR-0006, §6 Open decisions](../decisions/ADR-0006-SECURITY-HARDENING.md): hardening standards, profile inventory, vulnerability response and support lifecycle.
- [ADR-0007, §8 Open decisions](../decisions/ADR-0007-NETWORK-ARCHITECTURE.md): resolver integration, configuration schema, privilege boundaries, authentication, transaction persistence and upgrade migration. systemd-networkd and dnsmasq are accepted choices, not open backend selections.
- [ADR-0008, §6 Open decisions](../decisions/ADR-0008-DESKTOP-ARCHITECTURE.md): exact Desktop manifests/session combinations, Flatpak policy, update frontend, hardware validation and snapshot/backup tooling.

No package-resolution, installation, boot, security-update, upgrade or recovery tests were performed for this documentation review. The findings identify review and validation work; they do not establish runtime compatibility or authorize implementation.
