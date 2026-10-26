#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

bash -n scripts/validate-foundation-source.sh
bash scripts/validate-source.sh

required=(
  config/includes.chroot/etc/deskaone/foundation.conf
  config/includes.chroot/etc/sysctl.d/90-deskaone-base.conf
  config/package-lists/deskaone-foundation.list.chroot
  examples/networkd/10-deskaone-wired.network
  examples/package-lists/deskaone-resolved.list.chroot
)
for file in "${required[@]}"; do
  test -s "$file" || { printf 'Missing or empty: %s\n' "$file" >&2; exit 1; }
  printf 'OK file: %s\n' "$file"
done

grep -Fxq 'DESKAONE_NETWORK_BACKEND="systemd-networkd"' config/includes.chroot/etc/deskaone/foundation.conf
grep -Fxq 'DESKAONE_DNS_DHCP_SERVICE="dnsmasq"' config/includes.chroot/etc/deskaone/foundation.conf
grep -Eq '^[[:space:]]*net\.ipv4\.ip_forward[[:space:]]*=[[:space:]]*0[[:space:]]*$' config/includes.chroot/etc/sysctl.d/90-deskaone-base.conf
grep -Eq '^[[:space:]]*net\.ipv6\.conf\.all\.forwarding[[:space:]]*=[[:space:]]*0[[:space:]]*$' config/includes.chroot/etc/sysctl.d/90-deskaone-base.conf

shopt -s nullglob
package_lists=(config/package-lists/*.list.chroot)
(("${#package_lists[@]}" > 0)) || { echo "No active package lists found" >&2; exit 1; }
if grep -En '^[[:space:]]*systemd-resolved([[:space:]]*(#.*)?)?$' "${package_lists[@]}"; then
  echo "Unexpected active systemd-resolved package selection" >&2
  exit 1
fi
networkd_dir=config/includes.chroot/etc/systemd/network
if [[ -d "$networkd_dir" ]]; then
  network_files=("$networkd_dir"/*.network)
  (("${#network_files[@]}" == 0)) || { echo "Unexpected active networkd profile" >&2; exit 1; }
fi

for pkg in nftables wireguard-tools openssh-client; do
  grep -Fxq "$pkg" config/package-lists/deskaone-foundation.list.chroot || {
    printf 'Missing foundation package: %s\n' "$pkg" >&2
    exit 1
  }
done
printf 'Bootstrap 02 source-only checks passed. No package resolution, ISO build or boot test performed.\n'
