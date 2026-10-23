# Package and Repository Strategy — Design

**Status:** Design only.

Use official Debian Stable packages wherever possible. Proposed DesKaOne namespace: `deskaone-core`, `deskaone-release`, `deskaone-security`, `deskaone-server`, `deskaone-network`, `deskaone-desktop`, `deskaone-network-admin`, `deskaone-tools`.

Metapackages express edition dependencies; separate config ownership to preserve administrator changes. Avoid replacing Essential Debian packages. Do not disable APT signature verification or pull packages indiscriminately from Testing/Unstable.

Accepted channel design: DesKaOne **Stable**, **Testing** and **Unstable**, distinct from Debian suites ([ADR-0005, Decisions D2 — Three DesKaOne release channels](../decisions/ADR-0005-PACKAGE-REPOSITORY.md)). A separately signed overlay is accepted; repository metadata, key lifecycle and promotion details remain subject to technical design ([ADR-0005, Decisions D1, D3–D4 and D8](../decisions/ADR-0005-PACKAGE-REPOSITORY.md)). Phased reproducibility and signed manifests/provenance are accepted architecture, with implementation details still open ([ADR-0004, Decisions D4 and D6, §6 Open decisions](../decisions/ADR-0004-IMAGE-BUILD.md)). SBOM details remain a design topic.

See the [Debian compatibility review](../architecture/DEBIAN-COMPATIBILITY-REVIEW.md) for dependency, configuration ownership, security-maintenance and upgrade risks. Package names above remain proposals; this channel decision does not create packages or infrastructure.

Original project files may be MIT licensed; third-party components retain their own licenses and redistribution conditions. Track copyright, notices, and Debian source/package license obligations before redistribution.
