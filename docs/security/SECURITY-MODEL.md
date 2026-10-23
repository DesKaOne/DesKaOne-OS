# Security Model — Design

**Status:** Design only.

Threats include compromised package infrastructure, unauthorized remote management, privileged-service escalation, unsafe firewall/routing changes, leaked credentials and untested upgrades.

Controls:
- Debian security maintenance and signed APT repositories.
- Isolated builds, checksums, provenance, protected release-signing keys and key rotation plans.
- Minimal services, least privilege, SSH root-login restrictions, nftables baselines.
- Network management interface isolation, authenticated sessions, CSRF and rate limiting.
- Narrow privileged executor; audited changes; no unrestricted root web server.
- Network configuration validation, confirmation deadline and rollback.
- No secret material in Git; private vulnerability reports handled through SECURITY.md.
- Tests for boot, package integrity, upgrades, privilege boundaries and recovery.

Production publishing requires a separate security review and authorization.
