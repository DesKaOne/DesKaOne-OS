# Package and Repository Strategy — Design

**Status:** Design only.

Use official Debian Stable packages wherever possible. Proposed DesKaOne namespace: `deskaone-core`, `deskaone-release`, `deskaone-security`, `deskaone-server`, `deskaone-network`, `deskaone-desktop`, `deskaone-network-admin`, `deskaone-tools`.

Metapackages express edition dependencies; separate config ownership to preserve administrator changes. Avoid replacing Essential Debian packages. Do not disable APT signature verification or pull packages indiscriminately from Testing/Unstable.

Proposed DesKaOne channels: stable and testing, each signed with protected keys. Reproducible build inputs, SBOM/package manifests, provenance, key rotation and repository promotion policies require later design approval.

Original project files may be MIT licensed; third-party components retain their own licenses and redistribution conditions. Track copyright, notices, and Debian source/package license obligations before redistribution.
