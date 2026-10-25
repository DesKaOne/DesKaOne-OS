# ADR-0015 — Release Engineering & Image Distribution Architecture

**Project:** DesKaOne OS  
**Version:** Final R1  
**Status:** Accepted — architecture/documentation only  
**Decision date:** 2026-10-25  
**Scope:** Release versioning, image builds, validation, signing, channels, and distribution for Server, Network, and Desktop editions  
**Implementation authorization:** Not granted

## 1. Context and goals

DesKaOne OS uses a Debian Stable foundation and three modular editions. Future installers, cloud images, and edition-specific artifacts must be identifiable, verifiable, traceable to their inputs, and safely distributed. An artifact being built successfully does not prove that it boots, installs, or is safe to publish.

This ADR establishes the release-engineering architecture without selecting final build commands, deploying infrastructure, or producing images. ADR-0001 through ADR-0014 remain accepted and are not reopened.

Goals:
- Align support and version identity with the selected Debian Stable base.
- Preserve Debian-native build and package-management practices.
- Produce only validated, edition-appropriate artifacts.
- Maintain traceability from published bytes to source, packages, and build configuration.
- Authenticate official releases and support independently verified mirrors.
- Separate Testing and Stable releases, with explicit promotion gates and recovery guidance.

## 2. Approved decisions

### R01 — Debian-aligned release versioning

- Associate each DesKaOne OS release with its Debian Stable base release and a clearly identified DesKaOne release/revision.
- Keep OS/image release identifiers distinct from individual Debian package versions, security updates, and edition names.
- Record architecture, edition, build revision, source commit, and release channel in machine-readable release metadata.
- Preserve Debian Stable security and maintenance expectations; do not introduce an independent rolling-release policy.
- Define the exact version-string grammar, support windows, and release calendar in future technical design.

### R02 — Debian-native image build foundation

- Prefer maintained Debian-native tooling suitable for each artifact type rather than a custom image builder written from scratch.
- Use controlled, documented build environments and auditable build configurations.
- Follow the approved Debian APT/dpkg package, repository, signing, and edition-profile architecture.
- Do not assume one image-building tool must serve all installer, live, appliance, and cloud image formats.
- Select specific tools and pipelines only during separately approved technical design and implementation.

### R03 — Edition-specific artifact profiles

- Define artifact profiles for Server, Network, and Desktop rather than distributing one universally preloaded ISO.
- **Server:** installer and cloud/VPS images where supported and validated.
- **Network:** installer and appliance-targeted images where supported and validated.
- **Desktop:** installer and optional live environment where supported and validated.
- Each artifact must declare edition, architecture, supported boot/firmware mode, relevant hardware or platform constraints, and installation/recovery expectations.
- AMD64 remains the initial architecture; ARM64 support is deferred to its approved roadmap.
- An artifact type is a target capability, not a claim that it already exists.

### R04 — Pinned inputs and traceable build provenance

- Record source revision, Debian base, repository snapshot or equivalent resolvable package inputs, package selections/versions, build configuration, toolchain/environment metadata, and artifact identifiers.
- Use release manifests to connect inputs and output checksums.
- Aim for reproducibility in stages; distinguish **traceable builds** from **bit-for-bit reproducible builds** and verify reproducibility before claiming it.
- Ensure the release process can explain security-update incorporation and changes to pinned package inputs.
- Document any nondeterministic inputs or reproducibility exceptions.
- Protect provenance records from unauthorized alteration and associate them with authenticated release metadata.

### R05 — Signed metadata and artifact integrity

- Publish cryptographic checksums for artifacts and authenticate release manifests/metadata using appropriately managed signing keys.
- Explain how users obtain and verify the authentic release-signing public key or trusted fingerprint through an independent trusted channel.
- Manage signing keys separately from untrusted build workers and distribution mirrors where feasible; plan key rotation, revocation, compromise response, and recovery.
- Checksums detect accidental or malicious byte changes only when compared with authenticated expected values; unsigned checksums alone do not establish publisher authenticity.
- Verify the association between artifact bytes, checksums, signatures, version/channel, and provenance.
- Exact algorithms, signing infrastructure, and key custody procedures are deferred to technical design.

### R06 — Stable and Testing release channels

- Maintain **Stable** for validated production-oriented releases and **Testing** for explicit opt-in evaluation.
- Keep channel metadata and artifact identities distinct; promotion from Testing to Stable requires an explicit release decision and completed validation gates.
- Never silently switch installed systems from Stable to Testing or automatically promote unvalidated images.
- Document update and migration implications between channels; rollback is not assumed to be universally safe.
- The channels describe future release policy and do not authorize automatic publishing or update jobs.

### R07 — Official origin with independently verifiable mirrors

- Define an official publication origin for release metadata and artifacts; allow optional mirrors for availability and scale.
- Require clients and operators to verify signed official metadata and artifact integrity regardless of download source.
- Treat mirrors and CDNs as distribution mechanisms, not independent authorities for release trust.
- Publish clear artifact naming, checksums, signature-verification instructions, release notes, known limitations, and supported platforms.
- Design for stale, missing, partially synchronized, or malicious mirror content without silently accepting untrusted releases.
- Distribution must not require a proprietary DesKaOne account or hosted validation service.

### R08 — Release validation gates and recovery guidance

- Require explicit validation before Stable publication, including artifact integrity, installation/boot compatibility, edition package composition, security baseline, first-boot readiness, and recovery instructions.
- Validate artifacts against representative virtual/physical targets and declared platforms; do not generalize results to untested hardware.
- Confirm published metadata, signatures, checksums, provenance, and download paths correspond to the exact release bytes.
- Provide release notes, known issues, upgrade guidance, and rollback/recovery limitations.
- Recognize that OS rollback does not necessarily reverse database schema, application state, secrets, or user-data changes; reference the approved backup/recovery architecture.
- Define release rejection, withdrawal, and compromised-key response procedures before public distribution.
- Do not publish immediately merely because an image build succeeds.

## 3. Conceptual release flow

1. **Release planning:** choose Debian Stable base, edition, architecture, version/revision, channel, and target artifact profiles.
2. **Source and input selection:** identify approved source commit, package inputs, build configuration, and environment.
3. **Build:** produce edition-specific artifacts using suitable Debian-native mechanisms.
4. **Manifest and provenance:** record build inputs, outputs, hashes, and known reproducibility limitations.
5. **Validation:** verify install/boot, package/service composition, first boot, security, and recovery against declared targets.
6. **Signing:** authenticate release metadata and bind it to verified artifact checksums and provenance.
7. **Channel publication:** explicitly publish to Testing or, after Stable gates and approval, to Stable.
8. **Distribution and verification:** serve from official origin and optional mirrors, with independent signature/hash verification instructions.
9. **Lifecycle response:** maintain release notes, withdrawal guidance, key-compromise procedures, and recovery documentation.

This is an architectural sequence, not an executable CI/CD pipeline.

## 4. Edition artifact matrix

| Edition | Planned artifacts | Primary validation concerns |
| --- | --- | --- |
| Server | Installer and validated cloud/VPS images | Headless boot, storage, unique identity, remote recovery, essential services |
| Network | Installer and validated appliance profiles | Interface mapping, routing/firewall defaults, management recovery, hardware compatibility |
| Desktop | Installer and optional live images | Desktop boot, KDE Plasma/SDDM, graphics/session readiness, installation safety |

Artifacts are released only for platforms with validated support. No image type or architecture is declared production-ready by this ADR.

## 5. Alternatives considered

| Decision | Selected | Rejected as default |
| --- | --- | --- |
| R01 | Debian-aligned versioning | Independent rolling-release versioning |
| R02 | Debian-native image tools | Custom builder from scratch |
| R03 | Edition-specific artifact profiles | Universal all-purpose ISO |
| R04 | Pinned inputs and traceable provenance | Untracked build environments |
| R05 | Signed metadata and checksums | Unsigned checksums alone |
| R06 | Stable and opt-in Testing | Single undifferentiated channel |
| R07 | Official origin with verified mirrors | Unverified direct-download model |
| R08 | Release gates and recovery guidance | Publish immediately after build |

## 6. Consequences, risks, and mitigations

**Benefits:** Clear release identities, reuse of Debian tooling, smaller edition-specific deliverables, traceable build inputs, authenticated releases, testable channels, mirror resilience, and safer publication decisions.

**Risks:** Debian package inputs may change or become unavailable; build timestamps and environment details may prevent bit-for-bit reproducibility; signing keys may be compromised; mirrors may be stale; artifacts may fail on untested firmware/hardware; published images may contain cloned identities or outdated packages; rollbacks may conflict with mutable application data.

**Mitigations:** Immutable or resolvable input references, explicit provenance and exceptions, controlled signing and independent trust bootstrap, signature validation, representative platform tests, first-boot identity checks, release withdrawal procedures, and backup/recovery guidance.

A signature authenticates an authorized publisher's release metadata; it does not by itself prove the software is secure, free of vulnerabilities, or reproducible.

## 7. Future acceptance criteria — not executed

1. Verify release identifiers unambiguously encode Debian base association, DesKaOne revision, edition, architecture, and channel.
2. Validate chosen Debian-native tooling against each supported artifact type.
3. Test edition-specific package/service composition and declared firmware/platform compatibility.
4. Confirm manifests resolve exact source, package inputs, build configuration, environment, and produced artifacts.
5. Assess repeatability and independently test reproducibility before claiming bit-for-bit equivalence.
6. Verify release metadata signatures, artifact checksums, public-key trust bootstrap, and tamper detection.
7. Exercise signing-key rotation, revocation, compromise, and publication withdrawal procedures.
8. Test explicit Testing-to-Stable promotion gates and prohibit silent channel changes.
9. Verify official-origin and mirror downloads against the same authenticated metadata, including stale and partial mirror cases.
10. Validate installation, boot, first-boot identity, services, security posture, and recovery on representative Server, Network, and Desktop targets.
11. Check release notes, known limitations, supported-platform declarations, and backup/rollback guidance.
12. Confirm no release is published without the required explicit approvals and validated gates.

These are future requirements only; **no artifacts have been built or tested, and no PASS status is claimed**.

## 8. Deferred technical design

Exact version grammar; installer/cloud/live image formats; image-builder tool choices; build environment provisioning; package snapshot strategy; reproducibility measurement; provenance schema; release-signing algorithms and custody; mirror synchronization; release hosting; validation matrices; promotion controls; key-compromise runbooks; release scheduling; and artifact retention are deferred to separately approved technical design and implementation.

## 9. Approval and scope

The project owner approved R01=A, R02=A, R03=A, R04=A, R05=A, R06=A, R07=A, and R08=A, then separately approved publication of ADR-0015 Final R1 via feature branch, commit, pull request, squash merge, and verification on `main`.

This ADR inherits ADR-0001 through ADR-0014 without reopening accepted decisions.

**Phase 0 — Architecture & Documentation Only.** No source code, image-building pipeline, installer/ISO/cloud-image or package builds, host changes, deployments, runtime tests, releases, or GitHub Actions execution is authorized.
