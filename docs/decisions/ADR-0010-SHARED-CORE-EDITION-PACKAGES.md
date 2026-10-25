# ADR-0010 — Shared Core & Edition Package Architecture

**Project:** DesKaOne OS  
**Version:** Final R1  
**Status:** Accepted — documentation only  
**Decision date:** 2026-10-25  
**Scope:** Shared Core, Server, Network, and Desktop editions  
**Implementation authorization:** Not granted

## Context and goals

DesKaOne OS is a Debian 13 (Trixie)-based family with Server, Network, and Desktop editions. The editions must share a small, maintainable foundation without accidentally pulling in graphical, gateway, or general-purpose server workloads. Debian APT/dpkg remains the system of record for installed software. This decision defines package ownership and dependency boundaries; it does not reopen ADR-0001 through ADR-0009.

## Approved decisions

### P01 — Minimal shared core and modular extensions

- Define a small shared core for common DesKaOne identity, policy integration, package metadata, and genuinely edition-independent utilities.
- Keep the Debian kernel, systemd, APT/dpkg, security updates, and baseline utilities sourced from Debian wherever possible; do not fork or duplicate upstream packages without a justified need.
- Treat `deskaone-core` as a proposed metapackage naming convention, not a new replacement for Debian's essential/base package set.
- Do not include desktop environments, routing daemons, database servers, web servers, container engines, or optional monitoring stacks in the shared core.
- Document package ownership, optional dependencies, and compatibility before implementation.

### P02 — Independent edition metapackages

- Plan `deskaone-server`, `deskaone-network`, and `deskaone-desktop` as separate edition entry points, each depending on `deskaone-core` and its own required components.
- Server: minimal headless operation; no mandatory KDE or gateway stack.
- Network: routing/gateway management components according to ADR-0007; no automatic general-purpose server or KDE stack.
- Desktop: KDE Plasma, SDDM, Wayland-first defaults according to ADR-0008; no automatic routing/gateway service.
- Shared lower-level dependencies are allowed where functionally justified. Avoid edition-to-edition metapackage dependencies and cyclic dependencies.
- Edition packages express package selection, not an unconditional license to overwrite runtime state or enable network-facing services.

### P03 — Conservative dependency policy

- Use Debian control-file `Depends` only for essential, validated functional dependencies.
- Use `Recommends` selectively and document the impact of APT's default installation of recommended packages; never assume `Recommends` are disabled globally.
- Use `Suggests` or separate opt-in metapackages for nonessential heavy services, especially those that open ports, run persistent daemons, or significantly increase resource use.
- Keep version constraints as narrow as necessary, avoid needless pins and conflicts, and respect official Debian package ownership.
- Verify dependency closure per edition, including default APT behavior, architecture availability, and package removal scenarios.

### P04 — Administrator-owned configuration

- Preserve local administrator configuration across package upgrades. Follow Debian conffile and maintainer-script semantics.
- Do not silently replace modified files under `/etc`, overwrite secrets, or reset administrator-managed service settings.
- Package defaults should be distinguishable from local overrides, with migration and conflict behavior documented.
- Service enablement, initial provisioning, firewall changes, and network configuration must follow edition-specific safe defaults and explicit administrator choices.
- Provide documented recovery/rollback paths for potentially disruptive configuration migrations; never promise rollback is automatically atomic.

### P05 — APT-managed optional modules

- Optional functionality is installed through ordinary APT packages and optional DesKaOne metapackages, not an independent custom package manager.
- Candidate module categories include containers, databases, monitoring, VPN, and administrative utilities. The exact package names and supported combinations are deferred.
- Do not silently add third-party repositories, keys, services, firewall openings, or elevated privileges when a module is requested.
- Apply ADR-0005 signing, repository, package provenance, and channel-separation policies to all DesKaOne modules.
- Removing a module must not automatically destroy user data or unrelated packages; document purge behavior and dependencies.

### P06 — In-edition upgrades; manual cross-edition migration

- Support planned package upgrades within the installed edition using Debian's package lifecycle and the previously approved security-update policy.
- Do not offer automatic Server ↔ Network ↔ Desktop conversion in the initial architecture.
- Cross-edition migration requires explicit administrator action, inventory of installed packages and services, conflict assessment, backup, recovery planning, and validation of target edition requirements.
- Preserve data and local configuration wherever feasible; do not claim all workloads can migrate without downtime.
- Major Debian release transitions remain separately controlled and explicitly authorized.

### P07 — Debian-compatible package versions

- Use Debian Policy-compatible package names and `dpkg` version ordering, with DesKaOne revisions or suffixes chosen to avoid unintended replacement of official Debian packages.
- Distinguish DesKaOne OS release identity from individual package versions and from the underlying Debian suite.
- Maintain package metadata, changelogs, architecture declarations, repository origin, and upgrade paths compatible with APT/dpkg.
- Do not introduce a parallel universal package-version scheme that overrides Debian dependency semantics.
- Define exact suffix conventions and release automation only during later technical design.

### P08 — Dependency and lifecycle verification

Future implementation validation must include:
1. Dependency graph and cycle checks for `deskaone-core` and all three edition metapackages.
2. Clean installations using normal APT `Recommends` behavior and documented minimal-install variants.
3. Checks for unintended cross-edition packages, desktop stacks, gateway services, open ports, and excessive background services.
4. Package installation, upgrade, downgrade where supported, removal, and purge behavior.
5. Preservation of modified conffiles, credentials, service state, and administrator overrides.
6. Upgrade testing from supported repository channels and handling of partial/interrupted transactions.
7. Architecture availability and version ordering checks for AMD64; ARM64 remains a future approved phase.
8. Verification of signed package origins and prevention of unexpected third-party package replacement.
9. Recovery and backup procedures for failed upgrades and manual cross-edition migration.
10. Explicit documentation of measured resource footprint rather than unverified minimum hardware claims.

These are acceptance criteria, **not claims that tests have been run**.

## Proposed package relationship

```text
Debian 13 Trixie (kernel, systemd, APT/dpkg, base utilities)
  └── deskaone-core [minimal common metapackage]
      ├── deskaone-server  [headless edition requirements]
      ├── deskaone-network [network/gateway edition requirements]
      └── deskaone-desktop [KDE Plasma desktop requirements]

Optional, explicitly installed APT modules:
  containers | databases | monitoring | VPN | utilities
```

This is a conceptual dependency diagram. It is not a concrete Debian control file, package build manifest, or implementation.

## Alternatives considered and rejected as defaults

| Decision | Selected | Not selected |
| --- | --- | --- |
| P01 | Minimal shared core | Full universal core |
| P02 | Separate edition metapackages | Single universal edition metapackage |
| P03 | Minimal Depends, controlled Recommends | Broad automatic Recommends |
| P04 | Preserve administrator overrides | Always overwrite from packages |
| P05 | Optional modules via APT | Custom module package manager |
| P06 | In-edition upgrades, manual edition migration | Automatic edition conversion |
| P07 | Debian-compatible package versions | Separate incompatible version scheme |
| P08 | Dependency graph, clean install, lifecycle tests | Basic installation-only testing |

## Consequences, risks, and mitigations

**Benefits:** Reduced base footprint and attack surface, clear edition separation, Debian-native maintenance, optional workloads, safer upgrades, and auditable package provenance.

**Risks:** APT `Recommends` can unexpectedly install packages; metapackage removal may not remove all installed dependencies; configuration scripts can cause remote lockout; repository precedence can replace upstream packages; edition migrations may involve incompatible services or data layouts; package versions may sort unexpectedly. Mitigate with dependency-closure reviews, policy-controlled repositories, safe maintainer scripts, explicit module opt-in, staged lifecycle tests, and documented recovery.

## Deferred technical design

Exact `debian/control` files, package dependency lists, module names, version suffix rules, default conffiles, maintainer-script policy, APT pinning details, repository publication automation, test harnesses, migration runbooks, and edition resource measurements remain future tasks requiring separate approval.

## Existing architecture boundaries

This ADR **inherits** the already approved ADR-0001 through ADR-0009 without reopening them. Debian Stable and package trust remain foundational; Server stays headless, Network stays gateway-focused, and Desktop stays KDE-focused. No cross-edition conversion, package, repository, installer, ISO, or cloud image is implemented by this decision.

## Approval and scope

The project owner approved P01=A, P02=A, P03=A, P04=A, P05=A, P06=A, P07=A, and P08=A, and separately approved publication of this Final R1 via feature branch, commit, pull request, squash merge, and verification on `main`.

**Phase 0 — Architecture & Documentation Only.** No source-code implementation, host modification, package/ISO/image build, deployment, or GitHub Actions execution is authorized.
