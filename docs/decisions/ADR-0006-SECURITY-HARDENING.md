# ADR-0006 — System Security, Identity, and Hardening

**Project:** DesKaOne OS  
**Document version:** Final R1  
**Status:** Accepted — architecture/documentation only  
**Decision date:** 2026-10-24  
**Scope:** Shared Core, Server, Network, Desktop  
**Initial architecture:** AMD64  
**Project phase:** Phase 0 — Architecture & Documentation  
**Implementation authorization:** Not granted

## 1. Context

DesKaOne OS is a Debian 13 (Trixie)-based distribution with Server, Network, and KDE Plasma Desktop editions. The distribution needs a shared security foundation supporting least-privilege administration, network exposure control, application confinement, security auditing and safe recovery, without applying inappropriate restrictions uniformly across different deployment environments.

This ADR extends ADR-0001 through ADR-0005. It establishes architecture and future acceptance criteria only.

## 2. Decisions

### D1 — Identity and privileged administration

- Use individual **non-root administrator accounts** and **sudo** for privileged operations.
- Disable **direct remote root login** by default; preserve approved local/rescue recovery.
- Apply least privilege to service accounts and administrative roles.
- Prohibit shared default passwords; securely establish credentials during installation/provisioning.
- Make privileged actions attributable to an administrator where practical.
- **Server:** Support controlled automation and remote administration.
- **Network:** Future dashboard uses explicit role-based authorization; dashboard privileges must not implicitly confer unrestricted OS root access. Privileged backend actions require narrow, auditable boundaries.
- **Desktop:** Use **polkit** for approved graphical privileged operations and sudo for command-line administration.

### D2 — Native nftables firewall

Adopt **nftables** as the firewall foundation with edition-specific policies:

- Validate rules before activation; document persistence, boot behavior, management-access protection and recovery.
- **Server:** Default-deny unsolicited inbound traffic; allow explicitly enabled services, ensuring a viable administration path before restrictive rules are applied.
- **Network:** Distinguish device-local from forwarded traffic, WAN/LAN zones, routing/NAT/VPN, and management exposure. No unintended open forwarding or public management access. Use safe-apply and rollback.
- **Desktop:** Default-deny unsolicited inbound traffic; local discovery/application exceptions only when approved. No public remote-management exposure by default.
- Outbound and forwarding policy must be explicit rather than inferred from inbound defaults.

Exact rulesets and management interfaces are deferred.

### D3 — SSH key-first

- Prefer **SSH public-key authentication**; disable remote root SSH login by default.
- Do not automatically enable password authentication for publicly exposed SSH services.
- SSH server installation and enablement are edition-dependent.
- **Server:** SSH may be enabled via an explicitly selected installer/cloud-provisioning path; ensure a usable administrator authentication method before restricting access. Cloud-init may provision authorized keys.
- **Network:** Restrict SSH to approved management networks/interfaces; disable WAN exposure by default; provide recovery from lockout.
- **Desktop:** SSH server disabled by default; explicit administrator action required to enable it.
- Ensure unique SSH host keys and machine identities; regenerate identities in provisioned images where required.
- Log relevant SSH authentication and security events.

### D4 — AppArmor mandatory access control

- Adopt **AppArmor enabled by default** across editions, with enforcement of **validated profiles**.
- Reuse suitable Debian-compatible profiles; test confinement against required functionality.
- Make denials observable; manage custom DesKaOne profiles through controlled package releases.
- **Server:** Prioritize network-facing services and privileged daemons.
- **Network:** Prioritize management, network controllers and credential-handling services.
- **Desktop:** Prioritize system services and supported applications without unnecessarily breaking desktop workflows.
- Do not claim universal confinement for unprofiled or unvalidated third-party applications.

### D5 — Shared and edition-specific audit logging

Shared security-event baseline:

- Authentication successes/failures, privilege escalation, account/permission changes.
- Firewall and security-policy changes, SSH security events, AppArmor denials.
- Critical service failures and security-update activity.

Edition-specific focus:

- **Server:** Remote administration, privileged services, security-sensitive changes.
- **Network:** Firewall/routing/VPN changes, dashboard administration, management access, safe-apply confirmation and rollback.
- **Desktop:** Privileged graphical actions and system security changes, while minimizing collection of personal activity.

Use Debian-compatible logging, controlled retention/rotation, restricted log access and optional explicitly configured centralized forwarding. Never intentionally log passwords, tokens, private keys or unnecessary personal content. Choose journald/auditd/collectors later. Logging is **not** assumed tamper-proof.

### D6 — Balanced baseline and progressive hardening

Baseline: secure first installation, least privilege, minimal network exposure, safeguarded security updates, validated AppArmor, security-event visibility, credential protection, recoverability and Debian compatibility.

Progressive, validated additions may include systemd service sandboxing, stricter AppArmor profiles, kernel security settings, service isolation, expanded audit rules, network segmentation and edition-specific profiles. Evaluate operational impact, compatibility, resources and recovery before enforcement; do not maximize restrictions at the expense of reliable function.

### D7 — Network safe-apply and recovery

For changes to firewall, routing, interfaces and management connectivity:

1. Validate proposed configuration before activation.
2. Apply candidate configuration temporarily.
3. Require confirmation within a bounded period.
4. Automatically revert when confirmation is absent.
5. Recover from failed validation/activation.
6. Preserve a known-good configuration.
7. Audit application, confirmation and rollback.

Test realistic connectivity loss and service restarts. Exact timeout, transaction mechanism and recovery design remain open.

### D8 — Secrets and credential protection

- No shared default passwords, embedded production tokens, private keys or credentials in installation images.
- Generate unique machine credentials where needed; restrict sensitive file permissions.
- Keep secrets out of logs and management APIs; document rotation/recovery.
- Separate dashboard authorization from privileged OS execution.
- Follow ADR-0004/0005 for release and repository signing credentials.
- Define secure initial administrator enrollment before release.

### D9 — Security updates and vulnerability response

Consistent with ADR-0001 and ADR-0005:

- Track Debian advisories and applicable DesKaOne vulnerabilities.
- Support eligible automatic security updates with safeguards and no uncontrolled reboot.
- Keep major Debian upgrades administrator-initiated.
- Maintain vulnerability reporting/triage and urgent package-fix procedures.
- Define support and end-of-life policies.
- Do not claim guaranteed patch timing or comprehensive vulnerability immunity.

### D10 — Compatibility with prior ADRs

Preserve Debian 13 Trixie, Debian Installer/Calamares, GRUB 2 and phased Secure Boot, ext4/Btrfs defaults, optional LUKS2, recovery requirements, Debian-native image builds, signed manifests, overlay APT repositories, protected package priorities and release channels. Incompatible changes require explicit architecture review.

## 3. Alternatives considered

| Alternative | Assessment |
| --- | --- |
| Root as primary administrator | Rejected as default |
| Non-root + sudo; Desktop polkit | **Selected** |
| UFW as universal foundation | Not selected |
| Native nftables by edition | **Selected** |
| SSH passwords enabled by default | Not selected |
| SSH key-first, remote root disabled | **Selected** |
| Optional AppArmor | Not selected |
| AppArmor enabled with validated profiles | **Selected** |
| Minimal journald-only auditing | Insufficient for all editions |
| Shared events plus edition-specific audit | **Selected** |
| Strict universal hardening immediately | Higher compatibility/recovery risk |
| Balanced baseline, progressive hardening | **Selected** |

## 4. Consequences

**Benefits:** Consistent security baseline, reduced root reliance and network exposure, Debian-native firewall management, key-first remote administration, validated application confinement, security-event visibility and safe Network Edition recovery.

**Risks:** Firewall lockout; SSH provisioning failure; AppArmor compatibility regressions; audit storage/privacy impact; update disruption; hardening incompatibility; safe-apply complexity; local recovery security.

## 5. Future verification requirements

These are **future acceptance criteria, not completed tests**:

1. Secure administrator enrollment.
2. Correct sudo authorization.
3. Correct Desktop polkit behavior.
4. Remote root SSH login disabled.
5. Working key-based SSH where enabled.
6. Desktop SSH server off by default.
7. No unintended Network WAN management exposure.
8. nftables loading and persistence.
9. Default inbound restrictions.
10. Network forwarding/NAT correctness.
11. Safe-apply rollback after failed changes.
12. AppArmor operation and profile compatibility.
13. Security-event auditing.
14. Log access, retention and rotation.
15. No embedded default credentials.
16. Unique SSH host keys/machine identity.
17. Safeguarded security-update behavior.
18. No uncontrolled automatic reboot.
19. Recovery from lost remote administration.
20. Debian 13 and prior-ADR compatibility.

## 6. Open decisions

- Initial admin provisioning, SSH key enrollment and recovery.
- Exact nftables policies and Network zone/interface model.
- Safe-apply timeout, transaction and confirmation mechanisms.
- Dashboard RBAC and privileged operation boundaries.
- AppArmor profile inventory and enforcement rollout.
- Logging backends, audit schema, retention and forwarding.
- Secret storage and rotation.
- systemd/kernel hardening standards.
- Security baseline tests, vulnerability response and support lifecycle.

## 7. Phase restrictions

**Phase 0 — Architecture & Documentation Only.** This ADR does **not** authorize administrator account changes, sudo/polkit changes, firewall rules, SSH changes, AppArmor profiles, audit services, kernel/systemd configuration, credentials, Network management services, development/production host changes or Phase 1 implementation. Implementation requires separate explicit approval.

## 8. Approval record

On **2026-10-24**, the project owner selected non-root + sudo/polkit, native nftables, SSH key-first, AppArmor, shared plus edition-specific audit, and balanced progressive hardening. The owner subsequently **approved Final Draft R1 for documentation publication**.
