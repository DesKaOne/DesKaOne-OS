# ADR-0002 — Installation, Boot Architecture, and Cloud Provisioning

**Project:** DesKaOne OS  
**Version:** Final R1  
**Status:** Accepted — architecture/documentation only  
**Decision date:** 2026-10-24  
**Scope:** Shared Core, Server, Network, Desktop  
**Initial architecture:** AMD64  
**Implementation authorization:** Not granted

## 1. Context

DesKaOne OS is based on Debian 13 (Trixie) and has three editions: Server (VPS, bare metal and homelab), Network (routers, gateways, firewalls and VPN appliances), and Desktop (KDE Plasma workstations). Their installation requirements differ: headless and automated operation for Server/Network, and an approachable graphical installer for Desktop. All must retain Debian compatibility and recoverability. This ADR builds on ADR-0001.

## 2. Decisions

### D1 — Hybrid installer

**Server Edition**
- Use **Debian Installer** for a text-based, headless-friendly installation.
- Plan Debian-compatible unattended installation and diagnostic logging.
- Avoid graphical desktop dependencies.

**Network Edition**
- Use **Debian Installer** for minimal text-based installation.
- Design safe interface selection and initial networking to avoid loss of administrator access.
- Do not expose public management interfaces or open proxy services by default.
- Validate management connectivity and recovery before release.

**Desktop Edition**
- Use **Calamares** as the planned graphical installer within a **KDE Plasma Live ISO**.
- Design guided installation with clear disk selection, partitioning, encryption, localization, accessibility and failure recovery.
- Validate Calamares integration with Debian Trixie in an approved implementation phase.

Minimize installer customization and document any divergence from upstream.

### D2 — AMD64 boot compatibility

- Target **UEFI and Legacy BIOS** boot for initial AMD64 releases.
- Test both paths in virtual machines and representative physical hardware.
- Support is conditional on verified hardware and firmware behavior; it is not a promise of universal compatibility.
- ARM64 boot decisions remain outside this initial scope.

### D3 — Bootloader

- Use Debian-maintained **GRUB 2** packages for both supported boot modes.
- Select Debian's appropriate EFI GRUB components for UEFI and BIOS GRUB components for legacy boot.
- Preserve compatibility with Debian kernel and bootloader updates.
- Test recovery and failed bootloader-update scenarios.
- No custom GRUB fork by default.

### D4 — Phased Secure Boot

- Prefer the supported Debian-compatible **shim → GRUB → kernel** signed boot chain.
- Do not automatically disable Secure Boot or claim compatibility for unsigned custom boot artifacts.
- Validate the **complete DesKaOne boot chain** before advertising Secure Boot support for a particular image or configuration.
- Explicitly identify unsupported configurations when validation is incomplete.
- Defer signing, key enrollment, revocation, rotation, recovery and custom artifact handling to a separate technical design.

### D5 — VPS/cloud provisioning

- Plan **Server Edition cloud images** with **cloud-init**.
- Support initial user setup, SSH key injection, hostname configuration and compatible provider metadata.
- Do not distribute reusable credentials, private SSH host keys or machine-specific identities in images.
- Distinguish generic images from provider-specific variants and validate chosen providers/hypervisors.
- Cloud-based Network Edition deployment requires a separate connectivity, provider and recovery review.
- Desktop cloud images are not in the initial scope.
- These are design targets, not claims of existing images.

### D6 — Installation safety

- Require explicit confirmation for destructive disk actions and identify target disks clearly.
- Do not silently erase partitions or embed shared secrets in installation media.
- Unattended destructive actions require explicit administrator-supplied configuration.
- Provide understandable failures, troubleshooting logs, and documented recovery paths.
- Verify published installation media integrity and authenticity before release.

### D7 — Upstream maintainability

- Prefer Debian-maintained installer, bootloader and kernel components.
- Isolate and document DesKaOne-specific modifications.
- Ensure installation and boot decisions do not silently break Debian security updates or major-release migration.
- Share edition-independent installation foundations where practical.

## 3. Alternatives considered

| Alternative | Assessment |
| --- | --- |
| Debian Installer for all editions | Simpler, but less aligned with graphical Desktop goals |
| Calamares for all editions | Unsuitable for headless Server/Network |
| Hybrid Debian Installer + Calamares | **Selected** |
| UEFI only | Excludes legacy AMD64 systems |
| UEFI + Legacy BIOS | **Selected** |
| systemd-boot alone | Does not meet both boot-mode requirements |
| Debian GRUB 2 | **Selected** |
| Secure Boot disabled by default | Not selected as a general policy |
| Debian-compatible phased Secure Boot | **Selected** |
| ISO-only VPS provisioning | Possible fallback, not preferred cloud approach |
| Cloud images + cloud-init | **Selected** for Server |

## 4. Consequences

**Benefits:** Edition-appropriate installation, Debian upstream reuse, broader AMD64 boot coverage, a defined Secure Boot validation path, cloud-ready Server provisioning, and lower maintenance burden than fully custom installers.

**Risks and costs:** Two installer frameworks increase the test matrix; Calamares/Live ISO integration needs engineering; BIOS adds compatibility cases; Secure Boot requires complete-chain verification; cloud-init and metadata vary by provider; unattended installation needs safeguards and recovery testing.

## 5. Edition-specific requirements

- **Server:** Text-based installation, planned unattended provisioning, minimal dependencies, cloud-init, SSH-key-based initial access where supported, remote recovery documentation.
- **Network:** Text-based installation, safe interface selection, secure initial management, no publicly exposed management UI by default, connectivity validation and recovery, no default open proxy.
- **Desktop:** KDE Plasma Live environment, Calamares installer, guided disk operations, accessibility/localization, clear destructive-action confirmations, installation and boot recovery documentation.

## 6. Future verification requirements

These are **future acceptance criteria**, not tests already performed:

1. Successful AMD64 UEFI installation and boot.
2. Successful AMD64 Legacy BIOS installation and boot.
3. Correct GRUB installation and recovery.
4. Server installation without graphical dependencies.
5. Network installation and management connectivity.
6. Desktop Live ISO boot and Calamares installation.
7. Destructive disk-operation safeguards.
8. Recovery from interrupted or failed installation.
9. Boot behavior after kernel/security updates.
10. Complete Secure Boot chain validation for supported configurations.
11. Cloud image initialization with cloud-init.
12. Regeneration of SSH host keys and machine identity for new instances.
13. Cloud metadata and network provisioning compatibility.
14. Media integrity and authenticity verification.
15. Compatibility with Debian 13 Trixie packages.

## 7. Open decisions

- Default filesystem, partition layout, swap and encryption.
- Installer automation format and unattended safeguards.
- ISO image generation, reproducibility and Desktop Live construction.
- Secure Boot signing, keys and revocation lifecycle.
- Cloud image formats, target providers and publishing/signatures.
- Recovery partition/rescue media.
- Detailed Network Edition first-boot configuration.

Each substantial topic requires a separate ADR or approved technical design.

## 8. Phase restrictions

**This ADR approves documentation and architecture only.** It does not authorize installer implementation, ISO or cloud image builds, GRUB changes, Secure Boot key generation, CI/CD, host changes, package creation or advancement to Phase 1. Any such work requires separate explicit authorization.

## 9. Approval record

The project owner confirmed on **2026-10-24**: hybrid installer (Debian Installer for Server/Network; Calamares for Desktop), UEFI + Legacy BIOS, Debian GRUB 2, phased Secure Boot, and cloud images with cloud-init for Server.

**Final documentation approval:** Confirmed in conversation before repository publication.
