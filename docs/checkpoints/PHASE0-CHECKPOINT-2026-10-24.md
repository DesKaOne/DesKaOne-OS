# DesKaOne OS — Phase 0 Checkpoint (2026-10-24)

**Status:** Phase 0 — Architecture & Documentation Only  
**Repository:** https://github.com/DesKaOne/DesKaOne-OS  
**Branch of record:** main  
**Last approved ADR:** ADR-0008 Desktop Edition Architecture  
**Next planned topic:** ADR-0009 Server Edition Architecture  
**Implementation authorization:** NOT GRANTED

## Project foundation

- Debian 13 Trixie base; Debian Stable security/release cadence.
- AMD64 first, ARM64 later.
- Three editions: Server (headless), Network (router/firewall/gateway), Desktop (KDE Plasma).
- Monorepo, shared core, edition-specific metapackages.
- GitHub Actions disabled; documentation changes via feature branch, PR, squash merge and verification on main.
- Main branch protected by a pull-request ruleset.
- User preference: architecture drafts prepared silently; only concise decision summaries and approval/revision checkpoints in chat. Do not commit unapproved ADR drafts.

## Approved decisions

| ADR | Topic | Key decisions | Publication |
| --- | --- | --- | --- |
| 0001 | Debian Base | Debian 13 Trixie, AMD64-first, official kernel/APT/systemd, signed overlay, safe updates | PR #8 |
| 0002 | Installer & Boot | Debian Installer for Server/Network, KDE Live + Calamares Desktop, GRUB 2, phased Secure Boot, cloud-init planning | PR #9 |
| 0003 | Storage & Recovery | ext4 Server/Network, Btrfs Desktop, optional LUKS2, independent backup/rescue, snapshots not backups | PR #10 |
| 0004 | Image Build | Debian-native debootstrap/live-build/installer tooling, edition profiles, staged reproducibility, signed release manifests | PR #11 |
| 0005 | Package Repository | Debian official + signed DesKaOne overlay, DesKaOne Stable/Testing/Unstable distinct from Debian suites, safeguarded updates | PR #12 |
| 0006 | Security Hardening | Non-root sudo, constrained SSH, AppArmor, nftables, safe-apply for Network Edition, audit and recovery | PR #13 |
| 0007 | Network Edition | systemd-networkd, dnsmasq, native routing/nftables, WireGuard-first, Go+HTMX+CLI, transactional rollback | PR #14 |
| 0008 | Desktop Edition | KDE Plasma, validated Wayland-first/X11 fallback, SDDM, minimal apps, APT+optional Flatpak, Debian drivers, Btrfs recovery | PR #15 |

All eight ADRs were reported merged and verified on main at their publication checkpoints. ADR-0008 squash merge commit: `00d7abfdd271b1acc590c654a7c017461f3c29bc`.

## ADR-0008 confirmed details

- KDE Plasma; Wayland preferred on tested hardware, X11 fallback only where available and validated.
- SDDM login manager.
- Minimal essential applications with optional bundles.
- APT primary, Flatpak optional with explicit remote trust/permission policy.
- Official Debian kernel and firmware; proprietary drivers optional and license-aware.
- Btrfs snapshots plus independent backups and rescue.
- Keep KDE Live ISO + Calamares, security, signed packages and Debian compatibility aligned with prior ADRs.

## Next: ADR-0009 — Server Edition Architecture

**Review architecture choices first; do not create or commit an ADR-0009 draft before final approval.**

Suggested decision areas:
1. Headless baseline and default services; minimize open ports.
2. Networking and remote administration: systemd-networkd, SSH key-first, firewall and recovery.
3. Provisioning: Debian Installer, cloud-init images, first-boot identity/SSH key safety.
4. Container support: optional Docker/Podman with Debian compatibility, no mandatory container runtime.
5. Updates and lifecycle: APT, safeguarded security updates, controlled reboots, backups.
6. Observability: journald/log rotation, basic health metrics and optional exporters.
7. Resource profiles: small VPS versus larger bare-metal, performance budgets and minimum requirements only after testing.
8. Security and storage: non-root admin, AppArmor, ext4 root, optional LUKS2, independent backups/rescue.

Prepare a short set of recommended defaults for user confirmation, then silently assemble ADR-0009 Final Draft R1 and present a concise approval/revision summary. After explicit approval, publish via feature branch -> commit -> PR -> squash merge -> verify main.

## Scope guardrails

No coding, service installation, host modifications, package builds, ISO generation, CI/CD, migrations to Phase 1 or implementation work without separate explicit authorization. All work remains design/documentation only.

## Resume prompt

> Bre, lanjutkan proyek DesKaOne OS dari checkpoint `docs/checkpoints/PHASE0-CHECKPOINT-2026-10-24.md` di repo `DesKaOne/DesKaOne-OS`. Delapan ADR (0001–0008) sudah approved dan merged ke main. Kita masih Phase 0 — Documentation Only. Mulai ADR-0009 Server Edition Architecture: beri ringkasan opsi keputusan dan rekomendasi, minta konfirmasi saya; draft lengkap silent saja, jangan tampilkan di chat. Jangan coding, commit ADR-0009, push, PR atau merge sebelum saya approve. Setelah approval, gunakan feature branch -> PR -> squash merge -> verifikasi main. GitHub Actions tetap disabled.
