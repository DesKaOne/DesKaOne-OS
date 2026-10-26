# DesKaOne OS — Bootstrap 05 Validation Planning R1

Status: **source-only validation plan**. No ISO build, package download, VM boot, host execution, CI or GitHub Actions is authorized or performed by this change.

## Scope and evidence levels
- **L0 — Source inspection:** file presence, metadata, script syntax, configuration intent, and inactive profile isolation. Passing L0 does not prove a working ISO.
- **L1 — Dependency/build readiness (future approval):** verify Debian 13 amd64 apt availability, dependencies, toolchain versions, mirrors, clean environment, and artifact naming.
- **L2 — ISO build (future approval):** isolated live-build invocation, recorded log, SHA256, size, toolchain metadata and provenance.
- **L3 — Boot/runtime (future approval):** independent BIOS and UEFI VM boots, live-session/login, network, DNS, service exposure, logs, shutdown.
- **L4 — Edition and recovery (future approval):** separately activated Desktop/Server images, installer/recovery and edition-specific behavior. Out of scope for shared-base scaffold.

## Acceptance matrix

| ID | Gate | Verification | Pass criterion | Current evidence |
| --- | --- | --- | --- | --- |
| SRC-01 | L0 | Bootstrap 01–04 source validators | All exit 0 in authorized environment | Not executed |
| SRC-02 | L0 | Review inactive edition profiles | No edition packages/config promoted into active live-build directories | Source review only |
| PKG-01 | L1 | Resolve all active packages against Debian 13 amd64 | No missing packages or unresolved dependency conflicts | Not tested |
| PKG-02 | L1 | Inspect transitive services/resolver ownership | DNS/DHCP and interface owners explicit; no unapproved activation | Not tested |
| BLD-01 | L2 | Build in disposable Debian 13 amd64 environment | Exit 0, expected ISO present, complete log and checksum | Not tested |
| BLD-02 | L2 | Record reproducibility inputs | Toolchain, mirrors, timestamps and build parameters captured | Not tested |
| BOOT-01 | L3 | BIOS VM boot | Reaches documented live login/session without critical errors | Not tested |
| BOOT-02 | L3 | UEFI VM boot | Reaches documented live login/session without critical errors | Not tested |
| SEC-01 | L3 | Inspect listening sockets and enabled services | No unapproved SSH, DHCP/DNS listeners or remote exposure | Not tested |
| NET-01 | L3 | Inspect network interfaces and resolver | Ownership matches approved shared-base policy; no unexpected forwarding | Not tested |
| OPS-01 | L3 | Capture boot and shutdown logs | No release-blocking errors; reproducible evidence stored | Not tested |
| EDT-01 | L4 | Desktop/Server activation | Edition-specific gates defined and approved before execution | Deferred |
| REC-01 | L4 | Btrfs/transactional recovery | Reversible, tested recovery procedure | Deferred |

## Stop conditions
Stop promotion on any unresolved package conflict, unexpected enabled network service, credential exposure, missing checksum/log, unsupported boot mode, unreviewed installer behavior, or mismatched network/resolver ownership. A static check cannot waive runtime gates.

## Review and authorization
- PR merge approves **only this source plan**, not executing the test commands.
- Each L1/L2/L3/L4 transition needs separate explicit authorization and an isolated environment.
- No automatic promotion of a candidate to bootable or release-ready status.
- A reviewer records evidence, environment, failure notes, and a go/no-go decision for each gate.
- Source-only preflight command (not run here): `bash scripts/validate-validation-source.sh` from `bootstrap/`.
