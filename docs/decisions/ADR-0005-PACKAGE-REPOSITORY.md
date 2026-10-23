# ADR-0005 — Package Repository, Updates, and Release Channels

**Project:** DesKaOne OS  
**Version:** Final R1  
**Status:** Accepted — architecture/documentation only  
**Decision date:** 2026-10-24  
**Scope:** Shared Core, Server, Network, Desktop, Package Distribution  
**Initial architecture:** AMD64  
**Project phase:** Phase 0 — Architecture & Documentation  
**Implementation authorization:** Not granted

## 1. Context

DesKaOne OS is a Debian 13 (Trixie)-based distribution with Server, Network and KDE Plasma Desktop editions. The project needs a secure way to distribute DesKaOne-specific packages while retaining Debian as the primary upstream package source, with controlled security updates, channel isolation, verifiable metadata, safe dependency resolution and recovery from failed updates.

This ADR extends ADR-0001 (Debian baseline), ADR-0002 (installer and boot), ADR-0003 (storage and recovery), and ADR-0004 (image build and reproducibility).

## 2. Decisions

### D1 — Debian official + DesKaOne overlay

- Official Debian repositories remain the primary source for upstream OS packages.
- A separately signed DesKaOne overlay provides project-specific metapackages, branding, configuration and approved optional integrations.
- Illustrative package names: `deskaone-core`, `deskaone-server`, `deskaone-network`, `deskaone-desktop`. These are **examples, not existing packages or finalized names**.
- Prefer dependencies on official Debian packages.
- Rebuilding or replacing Debian upstream packages requires explicit justification, compatibility testing and security review.
- Do not operate a full Debian mirror as the initial distribution strategy.

### D2 — Three DesKaOne release channels

- **Stable:** Validated DesKaOne packages for supported production installations.
- **Testing:** Integration and release-candidate validation before Stable promotion.
- **Unstable:** Early development and experimental packages; potentially breaking.

These channels are for **DesKaOne packages only**. They do **not** switch the Debian baseline to Debian Testing or Debian Unstable. All initial editions remain based on **Debian 13 Trixie** unless separately approved.

Channel transitions must be explicit. Stable installations must not silently receive Testing or Unstable packages.

### D3 — APT repository metadata

The future repository must follow Debian APT conventions: signed `InRelease` or `Release` metadata, package indexes, versioned artifacts, architecture/channel identification, consistent metadata and selected historical package retention.

Exact suite/component names are deferred. Metadata must accurately identify the DesKaOne origin and channel and avoid ambiguous APT package selection.

### D4 — Separate signing keys

- Use an **APT repository signing key** to authenticate repository metadata.
- Use a **different release-artifact signing key** to sign image/release manifests per ADR-0004.
- Scope APT repository trust to the specific DesKaOne source using Debian-supported mechanisms; do not require global trust for unrelated repositories.
- Define key generation, secure private-key storage, signing authorization, public-key distribution, rotation, expiration, revocation, compromise recovery and trust bootstrap in a separate design.
- **No signing keys are generated or deployed in Phase 0.**

### D5 — Safe security updates

- Plan automatic installation of eligible **Debian security updates with safeguards**, as established by ADR-0001.
- Restrict unattended updates to explicitly approved sources/suites.
- Record successes/failures and preserve administrator visibility.
- **No uncontrolled automatic reboots.**
- **Major Debian distribution upgrades remain manual** and require compatibility review.
- Stable DesKaOne package updates require validated release eligibility; automatic eligibility is deferred to a separate policy.
- Never silently promote Testing/Unstable packages into Stable installations.
- Server updates must account for availability/maintenance windows; Network updates for gateway connectivity and remote-management recovery; Desktop updates for understandable status and restart prompts.

### D6 — Protected APT package priority

- Prefer official Debian packages for ordinary upstream dependencies.
- Allow DesKaOne-specific packages to install normally.
- Prevent unintended Debian package overrides and cross-channel upgrades.
- Explicitly review packages replacing Debian functionality.
- Avoid broad pinning that blocks Debian security updates.
- Define and test actual APT preferences/pin values against dependency resolution **during authorized technical design**, not in this ADR.

Repository signatures establish origin/authenticity, not safe package selection.

### D7 — Package retention and recovery

- Retain selected prior DesKaOne package versions for controlled recovery.
- Combine compatible package-version reinstallation with configuration backups, rescue environments, full backups and Btrfs snapshots where appropriate.
- **Downgrades are not guaranteed rollbacks**: database migrations, configuration changes and dependency updates may be irreversible or incompatible.
- Package maintainers must document migrations, downgrade limitations and stateful recovery.
- Btrfs snapshots cannot be the universal default because Server and Network use ext4.

### D8 — Controlled package promotion

Intended lifecycle: **Unstable → Testing → Stable**, with compatibility, security and edition-specific validation before Stable publication. Emergency security releases may use expedited review but must preserve authenticity, compatibility checks and release records. Promotion gates require separate technical design.

### D9 — Package supply-chain security

Future distribution must verify source provenance, preserve build metadata, review third-party dependencies, respect licenses, protect signing credentials, restrict publishing rights, retain version history, record promotions and provide incident response for compromised packages/infrastructure. A signature does **not** prove package contents are safe.

### D10 — Prior ADR compatibility

Maintain Debian 13 Trixie, official Debian kernel/system components, Debian Installer/Calamares, GRUB 2 and phased Secure Boot, ext4/Btrfs defaults, optional LUKS2, edition recovery, Debian-native image building, and signed release manifests/provenance. Any incompatible change requires separate ADR review.

## 3. Alternatives considered

| Alternative | Assessment |
| --- | --- |
| Full Debian mirror | Rejected initially: operational overhead |
| Debian official + DesKaOne overlay | **Selected** |
| Stable only | Limited development isolation |
| Stable + Testing | Less separation for experiments |
| Stable + Testing + Unstable | **Selected** |
| Shared key for APT and artifacts | Rejected: shared compromise impact |
| Separate signing keys | **Selected** |
| All updates manual | Not selected for security updates |
| Security auto-updates with safeguards | **Selected** |
| APT defaults without protection | Risk of unintended overrides |
| Protected Debian priority | **Selected** |
| Snapshot-only rollback | Not suitable for all editions |
| Package retention + recovery | **Selected** |

## 4. Consequences

**Benefits:** Debian upstream compatibility; less mirror maintenance; isolation of experimental packages; separate trust domains; controlled security updates; lower risk of package overrides; practical recovery; edition-specific availability safeguards.

**Risks:** Three-channel release complexity; unsafe pinning could block security updates; signing-key compromise; storage cost for retained versions; non-reversible state migrations; availability impacts of automatic updates; repository outages; validation burden for package promotion.

## 5. Future verification requirements

These are **future acceptance criteria, not completed tests**:

1. Correct Debian 13 Trixie sources.
2. DesKaOne signed APT metadata verification.
3. Debian/DesKaOne repository trust isolation.
4. Installation of DesKaOne-specific packages.
5. Protection from unintended Debian package replacement.
6. Stable/Testing/Unstable channel isolation.
7. Explicit, predictable channel switching.
8. Correct selection of Debian security updates.
9. No uncontrolled automatic reboots.
10. Logging and recovery after failed updates.
11. Retention/reinstallation of selected previous package versions.
12. Cross-edition dependency compatibility.
13. Recovery from interrupted package operations.
14. Handling of expired/rotated signing keys.
15. Restricted repository publishing rights.
16. Stable package promotion validation.
17. No accidental experimental packages in Stable.
18. Compatibility with installer and image pipeline.

## 6. Open decisions

- Repository domain, hosting, mirrors and availability.
- Exact APT suite/component naming and repository management tools.
- Signing technology, key lifecycle, distribution and trust bootstrap.
- APT preferences/pinning values.
- Promotion gates, emergency security release procedure.
- Update scheduling, maintenance windows and eligibility.
- Package retention duration, versioning and dependency compatibility.
- Repository monitoring, incident response and downgrade/recovery procedures.

## 7. Phase restrictions

**Phase 0 — Architecture & Documentation Only.** This ADR does **not** authorize repository deployment, DNS changes, signing-key generation, package builds/publication, APT configuration, automatic-update configuration, mirrors, CI/CD, host changes or progression to Phase 1. All implementation requires separate explicit approval.

## 8. Approval record

On **2026-10-24**, the project owner selected: Debian official + DesKaOne overlay; Stable/Testing/Unstable channels; separate APT and release signing keys; safeguarded automatic security updates with manual major upgrades; protected APT package priority; package retention and recovery. Final documentation publication was subsequently authorized.
