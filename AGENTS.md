# AGENTS.md — DesKaOne OS

This policy applies to AI agents and contributors throughout the planned monorepo.

## Current authorization: documentation only

The project owner has approved architecture and documentation work, **not implementation**. Do not create source code, packages, images, CI workflows, deployment artifacts or system configuration; do not run builds or modify a host. Repository documentation changes are permitted only when explicitly requested. This documentation commit is specifically authorized.

## Source of truth

Read `docs/architecture/ARCHITECTURE.md`, `ROADMAP.md`, this file and applicable approved ADRs before making changes. Flag contradictions; do not invent approvals.

## Hard boundaries

- Never begin an implementation phase based only on architecture approval.
- Do not install/remove host packages, repartition disks, alter bootloaders, firewall, routing or production systems without explicit authorization.
- Do not replace Debian Essential packages, kernel, systemd or APT/dpkg without approved architecture changes.
- Do not mix Debian Stable with Testing/Unstable by default or disable APT signature checks.
- Do not commit secrets, private signing keys or tokens.
- Do not expose management interfaces, open proxies or unrestricted root services by default.
- Do not suppress package/script errors or bypass security checks to pass a build.
- Do not commit, push, merge, force-push or release without explicit authorization for that action.

## Monorepo ownership (future layout)

`docs/` specifications; `configs/` profiles; `packages/` Debian packaging; `components/` optional custom tools; `images/` edition composition; `build/` build orchestration; `tests/` verification. Shared Core changes must be reviewed across all editions.

## Edition constraints

- **Server:** headless and minimal; preserve SSH recovery; no surprise reboots or exposed services.
- **Network:** web and CLI must share validated operations; protect management plane; rollback connectivity-breaking changes; audit privileged changes.
- **Desktop:** KDE Plasma; keep developer tools optional; preserve user settings on upgrades.

## Workflow after a separately approved implementation phase

1. Confirm exact approved scope and affected paths.
2. Assess Debian compatibility, security and recovery impact.
3. Implement the smallest authorized change in an isolated environment.
4. Run relevant tests (unit, package, boot, security, upgrade and recovery as applicable).
5. Review diff and update documentation.
6. Report files changed, tests actually run, limitations, risks and Git status.
7. Stop at the phase gate; never advance automatically.

No claimed test, commit, release or deployment without evidence. For failures, preserve logs and report root cause; do not use unsafe workarounds.

## Architecture change control

Base distribution, architectures, kernel/init/package strategy, privilege model, installer, signing, network management and edition boundaries require an ADR, impact review and explicit approval.

**Final rule: when authorization is unclear, stop at analysis and ask.**
