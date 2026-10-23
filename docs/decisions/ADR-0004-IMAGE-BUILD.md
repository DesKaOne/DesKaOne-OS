# ADR-0004 — ISO Build, Image Pipeline, and Reproducibility

**Project:** DesKaOne OS  
**Version:** Final R1  
**Status:** Accepted — architecture/documentation only  
**Decision date:** 2026-10-24  
**Scope:** Shared Core, Server, Network, Desktop, Release Infrastructure  
**Initial architecture:** AMD64  
**Project phase:** Phase 0 — Architecture & Documentation  
**Implementation authorization:** Not granted

## 1. Context

DesKaOne OS is based on Debian 13 (Trixie), with Server, Network, and KDE Plasma Desktop editions. The project needs a maintainable way to produce installer ISO, Desktop Live ISO, and Server cloud images without diverging unnecessarily from Debian. Each edition requires a distinct installation workflow but should share a package baseline, security model, artifact identity and verification process.

This ADR extends ADR-0001 (Debian baseline), ADR-0002 (installer and boot), and ADR-0003 (storage and recovery).

## 2. Decisions

### D1 — Debian-native build tools

Adopt Debian-native image construction tools:

- **debootstrap:** Construct minimal Debian root filesystems.
- **live-build:** Build live environments and applicable image configurations.
- **Debian Installer tooling:** Produce or integrate Server/Network installation media.
- **Debian package tools:** Resolve and install package selections.
- **Debian GRUB 2 tooling:** Support UEFI and Legacy BIOS.

These tools serve different purposes. **live-build alone is not assumed to provide a fully functional Debian Installer ISO** for every required mode. The exact image assembly and installer integration must be validated in a separately authorized implementation phase. A custom Go image builder is not an initial requirement.

### D2 — Shared foundation with edition profiles

Use a shared foundation for Debian release/architecture selection, APT repository configuration and signature verification, shared base packages, metadata, security policy, naming and verification.

Edition profiles:

- **Server:** Minimal headless packages; Debian Installer ISO; optional cloud image with cloud-init.
- **Network:** Minimal appliance packages; Debian Installer ISO; safe initial networking and no default publicly exposed management or open proxy.
- **Desktop:** KDE Plasma Live ISO; Calamares; localization and graphical recovery.

Share common foundations without forcing identical runtime services, package sets or partition layouts.

### D3 — Planned artifacts

| Edition | Primary artifact | Additional planned artifact |
| --- | --- | --- |
| Server | Installer ISO | Cloud image |
| Network | Installer ISO | Appliance-specific image (future) |
| Desktop | Live ISO with Calamares | Additional hardware profiles (future) |

Server cloud images may use RAW or QCOW2, subject to provider/hypervisor validation. Images must address cloud-init metadata, network initialization, machine identity, SSH host-key regeneration, secret removal and cleanup. Provider support cannot be claimed before testing. ARM64 image/boot decisions are deferred.

### D4 — Phased reproducibility

**Stage A: Controlled inputs.** Record Debian release and architecture, repository URLs and signed metadata, package versions and dependency resolution, build-tool versions, configuration revision, build environment, and relevant timestamps. Evaluate immutable repository snapshots. Version pinning alone is insufficient.

**Stage B: Repeat-build validation.** Rebuild under controlled conditions; compare artifacts and document differences.

**Stage C: Bit-for-bit verification.** Aim for independent builds producing identical artifacts. Address nondeterministic timestamps, filesystem/archive metadata, file order, boot-image construction, compression, toolchain and environment. Do not label artifacts reproducible until verified.

### D5 — Release versioning

Use project-level **Semantic Versioning**, combined with a Debian baseline, edition, architecture and build revision in artifact identity.

Illustrative only:

`deskaone-os-desktop-1.0.0-debian13-amd64-build001.iso`

This is **not** an existing release. Before the first public release, define major/minor/patch compatibility policy and artifact/channel lifecycle. A build revision distinguishes outputs without silently redefining project version. Never misrepresent the actual Debian baseline.

### D6 — Signed integrity and provenance

Each official release should provide:

- SHA-256 checksums for artifacts.
- A manifest of artifacts and build metadata.
- A **cryptographic signature** over that manifest.
- Accurate provenance for source revision, inputs, tools and build environment.
- User-facing verification instructions.

Checksums detect changes but do not independently establish authenticity. Signatures provide authenticity only if users have an authenticated trusted signing key. Define key generation, secure storage, authorized signing, distribution, rotation, revocation, compromise recovery and practical separation from build hosts in separate technical design. Provenance must not claim unverified independent or trusted-build guarantees.

### D7 — Manual/local first

Begin future implementation with documented **manual/local builds** in controlled environments. Preserve build records and verification. Self-hosted automation may be designed later with separate approval. **GitHub Actions is not required.** Manual builds do not waive integrity or audit requirements.

### D8 — Supply-chain security

Future builds must verify Debian package sources, avoid unreviewed external scripts, minimize privilege, isolate signing secrets, record package/source inputs, respect third-party licensing and exclude embedded tokens, credentials, SSH host keys and machine-specific secrets. A successful build is not itself a security verification.

### D9 — Compatibility with earlier ADRs

Maintain Debian 13 Trixie, Debian Installer for Server/Network, Calamares for Desktop, AMD64 UEFI and BIOS, Debian GRUB 2, phased Secure Boot, GPT, ext4 Server/Network, Btrfs Desktop, optional LUKS2, edition-specific swap and hybrid recovery. Incompatible changes require explicit ADR review.

## 3. Alternatives considered

| Alternative | Assessment |
| --- | --- |
| Custom Go image builder initially | Rejected: complexity and maintenance |
| Debian-native tooling | **Selected** |
| Fully separate edition pipelines | Rejected as default: duplication |
| Shared foundation with edition profiles | **Selected** |
| Mandatory bit-for-bit reproducibility from first release | Not selected as immediate gate |
| Phased reproducibility | **Selected** |
| Calendar versioning | Considered, not selected |
| Project SemVer + Debian baseline + build revision | **Selected** |
| SHA-256 only | Insufficient for authenticity |
| Signed manifest + provenance | **Selected** |
| Self-hosted automation initially | Deferred |
| Manual/local builds first | **Selected** |

## 4. Consequences

**Benefits:** Reuse Debian tooling; avoid premature custom infrastructure; consistent cross-edition base; preserve distinct installers; define repeatability goals, release identity, authenticity and provenance; operate without hosted CI.

**Risks:** Distinct image paths increase testing; Debian Installer and Calamares integration need separate maintenance; manual operator error; mutable APT inputs; nondeterministic image metadata; signing key management; provider-specific cloud behavior; cross-edition coupling.

## 5. Future verification requirements

These are **future acceptance criteria, not completed tests**:

1. Debian 13 package-source authenticity.
2. Correct package selection by edition.
3. Server Installer ISO installation and boot.
4. Network Installer ISO installation and boot.
5. Desktop Live ISO boot and Calamares installation.
6. AMD64 UEFI boot.
7. AMD64 Legacy BIOS boot.
8. GRUB 2 installation and recovery.
9. Approved filesystem and partition defaults.
10. No embedded secrets or machine-specific identities.
11. Cloud-init on supported Server cloud images.
12. Regeneration of SSH host keys and machine identity.
13. SHA-256 checksum verification.
14. Manifest signature verification with an authenticated public key.
15. Accurate provenance records.
16. Controlled repeat-build comparison.
17. Secure Boot validation where advertised.
18. Compatibility with the Debian baseline.

## 6. Open decisions

- Debian Installer ISO assembly; live-build and Calamares integration.
- Build-profile repository layout and package manifests.
- Dependency locking, repository snapshots and update cadence.
- Reproducible build environment and timestamp normalization.
- Signing technology, key lifecycle and provenance format.
- Cloud image formats and supported providers.
- Distribution/mirrors, hardware minima, release channels and lifecycle.
- Build validation and possible self-hosted automation.

## 7. Phase restrictions

**Phase 0 — Architecture & Documentation Only.** This ADR does **not** authorize ISO/cloud-image generation, build scripts, installer integration, packages, signing keys, CI/CD, build server provisioning, repository infrastructure, changes to development/production systems, or progression to Phase 1. Implementation requires separate explicit approval.

## 8. Approval record

On **2026-10-24**, the project owner selected Debian-native build tools, shared edition profiles, phased reproducibility, project SemVer plus Debian baseline/build revision, signed manifest with SHA-256 and provenance, and manual/local builds first. Final documentation publication was subsequently authorized.
