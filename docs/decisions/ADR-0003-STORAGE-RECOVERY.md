# ADR-0003 — Filesystem, Partitioning, Encryption, and Recovery

**Project:** DesKaOne OS  
**Version:** Final R1  
**Status:** Accepted — architecture/documentation only  
**Decision date:** 2026-10-24  
**Scope:** Shared Core, Server, Network, Desktop  
**Initial architecture:** AMD64  
**Implementation authorization:** Not granted

## 1. Context

DesKaOne OS is a Debian 13 (Trixie)-based distribution with Server, Network, and KDE Plasma Desktop editions. Server storage prioritizes predictable operation and backup; Network prioritizes limited writes, power-loss recovery and retained management access; Desktop prioritizes user experience, data protection and snapshots. Storage must remain compatible with the official Debian kernel, GRUB, Debian Installer, Calamares, APT and dpkg. This ADR extends ADR-0001 and ADR-0002.

## 2. Decisions

### D1 — Edition-specific filesystem defaults

**Server:** Use **ext4** for the default root filesystem. Allow optional separate data filesystems and require independent backup; do not depend on native filesystem snapshots.

**Network:** Use **ext4** for the default root filesystem. Minimize unnecessary persistent writes and evaluate log rotation and storage endurance (including SSD/eMMC). Do not introduce read-only root or overlay-based storage without a separate ADR.

**Desktop:** Use **Btrfs** for the default root filesystem. Plan system/user-data subvolumes and system recovery snapshots. Snapshots do **not** replace independent backups. Compression, free-space management, retention and mount options remain technical-design questions.

ZFS and custom filesystem modules are not required for the initial release.

### D2 — Simple partitioning

- Require a root filesystem; make separate data partitions/filesystems optional.
- Avoid complex mandatory layouts.
- Plan guided partitioning and advanced manual partitioning where installer capabilities permit.
- Clearly identify destructive disk operations and require explicit confirmation.
- Btrfs subvolumes may logically separate system and user data without separate physical partitions.
- Exact mount options, subvolume names and sizes are deferred.

### D3 — GPT for UEFI and Legacy BIOS

- Use **GPT** for both initial AMD64 boot modes.
- **UEFI:** Provide an EFI System Partition (ESP) using a compatible FAT filesystem and Debian GRUB EFI components.
- **Legacy BIOS:** Provide a BIOS boot partition where required for GRUB on GPT and use Debian GRUB BIOS components.
- Defer partition sizing, alignment and bootloader details to verified technical design.

### D4 — Swap per edition

- **Server:** Swap optional, chosen based on memory and workload; a swapfile or swap partition may be appropriate. Swap is not a substitute for adequate RAM.
- **Network:** No swap by default; exceptions require documented justification. Avoid unnecessary writes to limited-endurance storage.
- **Desktop:** Plan a swapfile by default when technically supported; validate Btrfs swapfile constraints. Hibernation is not guaranteed and requires separate resume/encryption design.
- Exact swap sizing and memory-pressure handling remain open.

### D5 — Optional LUKS2 encryption

- Offer **optional LUKS2** encryption across editions where supported by the installer.
- Require informed administrator/user choice; explain passphrase and recovery-key responsibilities.
- Use Debian-supported cryptsetup/LUKS2 mechanisms; never embed shared keys in installation media.
- **Server:** Address unattended boot and remote recovery.
- **Network:** Address automatic power restoration and remote appliance access.
- **Desktop:** Validate graphical installer integration.
- TPM integration, remote unlocking, encrypted boot layout and recovery-key handling require separate design.

### D6 — Hybrid recovery

- Maintain **independent backups** and documented **rescue/recovery** workflows across editions.
- Use **Btrfs snapshots where applicable**, particularly for Desktop system recovery.
- **Server:** Verify backup/restore and rescue paths for filesystem, package and bootloader failures.
- **Network:** Back up configuration and recover management access; distinguish network configuration rollback from full OS recovery.
- **Desktop:** Define snapshot retention, space limits and restoration; keep user-data backups separate.
- Snapshots cannot protect against loss or destruction of the underlying storage.

### D7 — Storage safety

- Never silently overwrite user data during installation.
- Require explicit confirmation before destructive operations.
- Document repair limitations and recovery dependencies.
- Plan monitoring of storage utilization and filesystem errors.
- Minimize unnecessary writes on network appliances.
- Verify backups by testing restoration before release.
- Document offline recovery when credentials or network access may be unavailable.

### D8 — Upstream compatibility

- Remain compatible with Debian 13 Trixie, official Debian kernel, Debian Installer (Server/Network), Calamares (Desktop), Debian GRUB 2, APT and dpkg.
- Do not maintain custom filesystem or encryption forks for the initial release.

## 3. Alternatives considered

| Alternative | Assessment |
| --- | --- |
| ext4 for every edition | Simpler, but no native Btrfs snapshot capabilities |
| Btrfs for every edition | Additional complexity for Server and Network defaults |
| ext4 Server/Network + Btrfs Desktop | **Selected** |
| Complex mandatory partition layout | Rejected |
| Simple root + optional data | **Selected** |
| Swap enabled on all editions | Not selected |
| Edition-specific swap | **Selected** |
| Mandatory encryption everywhere | Not selected due to recovery/availability constraints |
| Optional LUKS2 | **Selected** |
| Snapshot-only recovery | Rejected; snapshots are not independent backups |
| Backup + rescue + applicable snapshots | **Selected** |
| GPT for both UEFI and BIOS | **Selected** |
| GPT for UEFI and MBR for BIOS | Not selected as default |

## 4. Consequences

**Benefits:** Appropriate defaults by edition; mature ext4 for Server/Network; Btrfs subvolumes/snapshots for Desktop; consistent GPT strategy; encryption choice balanced against operational recovery; independent backups; simple installer layout.

**Risks:** Multiple filesystem test paths; Btrfs snapshot space/retention management and swapfile constraints; LUKS2 complicating unattended boot; Network storage wear; GRUB BIOS/GPT partition requirements; backup recovery must be demonstrated.

## 5. Future verification requirements

The following are **future acceptance criteria, not completed tests**:

1. ext4 installation/boot on Server.
2. ext4 installation/boot on Network.
3. Btrfs installation/boot on Desktop.
4. UEFI/GPT/ESP installation.
5. BIOS/GPT/BIOS boot partition installation.
6. GRUB installation and recovery.
7. Safe guided partitioning and destructive-operation confirmation.
8. Btrfs subvolume/snapshot restoration.
9. Btrfs-compatible swapfile activation.
10. Network operation without default swap.
11. Optional LUKS2 setup and unlocking.
12. Recovery from encryption/boot configuration failures.
13. Verified backup and restore.
14. Recovery from interrupted installation and filesystem errors.
15. Debian 13 kernel and installer compatibility.

## 6. Open decisions

- ESP and BIOS boot partition sizing; root size and minimum disk requirements.
- Btrfs subvolume layout, mount options, snapshot tooling and retention.
- Swapfile sizing, hibernation and memory-pressure policies.
- LUKS2 key management, TPM integration, remote unlock and Secure Boot interaction.
- Backup format, destination, retention and restore drills.
- Rescue image and offline recovery workflow.
- Network log retention, write minimization and storage health alerting.

## 7. Phase restrictions

**Phase 0 — Architecture & Documentation Only.** This ADR does **not** authorize disk formatting, partitioning, installer/bootloader implementation, encryption configuration, snapshot or backup service deployment, ISO/cloud image generation, packages, CI/CD, changes to development/production hosts, or advancement to Phase 1. All implementation requires separate explicit approval.

## 8. Approval record

On **2026-10-24**, the project owner selected: mixed ext4 (Server/Network) and Btrfs (Desktop) filesystems; simple root plus optional data; edition-specific swap; optional LUKS2; hybrid backup/rescue/snapshot recovery; and GPT for UEFI and Legacy BIOS. Final documentation publication was subsequently authorized.
