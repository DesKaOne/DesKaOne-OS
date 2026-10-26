# DesKaOne OS — Bootstrap 01 R1

Initial **source-only** Debian 13 (Trixie) amd64 live-build scaffold.

## Scope
- `config/package-lists/deskaone-base.list.chroot`: candidate base packages.
- `config/includes.chroot/etc/deskaone-release`: DesKaOne identity marker; Debian `/etc/os-release` remains untouched.
- `scripts/prepare-build.sh`: generate live-build config.
- `scripts/build-iso.sh`: build an ISO and SHA256 checksums, **not executed**.

## Source-only validation
Run `bash scripts/validate-source.sh` from the `bootstrap` directory. This checks Bash syntax and required scaffold files only; it does **not** prove the ISO builds or boots.

## Proposed usage (not executed)
On an approved Debian build host with `live-build` installed:

```bash
cd bootstrap
bash scripts/prepare-build.sh
bash scripts/build-iso.sh
```

The scripts are currently stored without executable file mode; invoke them with `bash` as shown above.

## Open technical items
- The package list is provisional; validate package names, networking integration, firmware/boot behavior, and reproducibility on an approved build environment.
- `dnsmasq` and systemd-networkd configuration are not yet provided; the networking ADR must govern their integration.
- `iso-hybrid` is a live image proposal, not a validated installed OS image.
- Snapshot, rollback, VM isolation, package manifest and smoke tests remain pending.
- No build or host/VM execution was performed.
