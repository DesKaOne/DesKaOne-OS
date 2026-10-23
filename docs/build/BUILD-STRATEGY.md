# Build and Release Strategy — Design

**Status:** Design only; no build tools or workflows created.

AMD64-first. Candidate Debian tools include debootstrap and live-build; exact installer/image builder remains open. Isolate builds from developer hosts, pin upstream baseline and record inputs.

Proposed pipeline: resolve signed package sources → compose edition manifest → build image → install/boot VM tests → security/upgrade/recovery tests → record checksums and provenance → protected signing → explicit release approval → publish.

Release metadata: DesKaOne version, Debian codename, edition, architecture, manifest, build ID, signatures, test report, known issues, upgrade/recovery instructions.

ARM64 later: separate generic UEFI and device-specific firmware/bootloader validation. Secure Boot is not assumed supported until signing architecture is approved.

No publication without separate authorization.
