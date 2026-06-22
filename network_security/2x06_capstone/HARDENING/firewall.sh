#!/usr/bin/env bash

_ROOT=1
if [[ "$(id -u)" -ne 0 ]]; then
  _ROOT=0
  echo "Non-root: generating nft policy and rollback commands."
fi

WAN="${WAN:-eth0}"
LAN="${LAN:-eth1}"
WG="${WG:-wg0}"
VPN_NET="${VPN_NET:-10.30.0.0/24}"
ADMIN_VPN="${ADMIN_VPN:-10.30.0.5/32}"
FINANCE_VPN="${FINANCE_VPN:-10.30.0.15/31}"
DMZ_FTP_IP="${DMZ_FTP_IP:-10.42.191.50}"
DB_HOST_IP="${DB_HOST_IP:-192.168.1.53}"
PASSIVE_MIN="${PASSIVE_MIN:-39000}"
PASSIVE_MAX="${PASSIVE_MAX:-41000}"

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
ALT_PATH="${PWD}/artifacts/firewall_${TIMESTAMP}"
mkdir -p "${ALT_PATH}"
RULE_FILE="/root/logicorp-nft-${TIMESTAMP}.nft"
RBACK_SH="/root/logicorp-firewall-rollback-${TIMESTAMP}.sh"
if [[ "${_ROOT}" -eq 0 ]]; then
  RULE_FILE="${ALT_PATH}/logicorp.nft"
  RBACK_SH="${ALT_PATH}/rollback.sh"
fi

cat > "${RBACK_SH}" << 'EOF'
#!/usr/bin/env bash
nft flush ruleset
EOF
chmod +x "${RBACK_SH}"

RBACK_PID=""
if [[ "${_ROOT}" -eq 1 ]]; then
  echo "[+] 1-minute automatic rollback timer"
  nohup bash -c "sleep 60; ${RBACK_SH}" >/tmp/rollback.log 2>&1 &
  RBACK_PID="$!"
  echo "Rollback timer PID: ${RBACK_PID}"
else
  echo "Rollback written to ${RBACK_SH}"
fi

cat > "${RULE_FILE}" << 'EOF'
flush ruleset

table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;
    ct state established,related accept
    
    iif "lo" accept
    iifname "${WAN}" udp dport 51820 accept
    iifname "${WG}" ip saddr { ${ADMIN_VPN_NET} } tcp dport 22 accept
    iifname "${WG}" ip saddr { ${FINANCE_VPN_NET} } tcp dport 21 accept
    iifname "${WG}" ip saddr { ${FINANCE_VPN_NET} } tcp dport ${PASSIVE_MIN}-${PASSIVE_MAX} accept
  }

  chain forward {
    type filter hook forward priority 0; policy drop;
    ct state established,related accept

    iifname "${WG}" ip saddr { ${ADMIN_VPN_NET} } oifname "${LAN}" accept
    iifname "${WG}" ip saddr { ${FINANCE_VPN_NET} } ip daddr ${DMZ_FTP_IP} tcp dport 21 accept
    iifname "${WG}" ip saddr { ${FINANCE_VPN_NET} } ip daddr ${DMZ_FTP_IP} tcp dport ${PASSIVE_MIN}-${PASSIVE_MAX} accept
    iifname "${LAN}" ip daddr ${DB_HOST_IP} tcp dport 3306 accept
    iifname "${WAN}" tcp dport 22 drop
    iifname "${LAN}" ip daddr ${DB_HOST_IP} tcp dport != 3306 drop
  }

  chain output {
    type filter hook output priority 0; policy drop;
    ct state established,related accept
    
    oif "lo" accept
    udp dport 53 accept
    udp dport 123 accept
    tcp dport 443 accept
    tcp dport 80 accept
    udp dport 51820 accept
    tcp dport 21 accept
    tcp dport ${PASSIVE_MIN}-${PASSIVE_MAX} accept
    tcp dport 22 accept
    tcp dport 3306 accept
  }
}

table ip nat {
  chain postrouting {
    type nat hook postrouting priority 100; policy accept;
    
    ip saddr ${VPN_NET} oifname "${WAN}" masquerade
  }
}
EOF

if [[ "${_ROOT}" -ne 0 ]]; then
  echo "Applying nftables policy with file"
  nft -f "${RULE_FILE}"
else
  echo "Applying command: sudo nft -f \"${RULE_FILE}\""
fi

if [[ "${_ROOT}" -ne 0 ]]; then
  mkdir -p /etc/nftables.d
  cp "${RULE_FILE}" /etc/nftables.d/logicorp.nft
  if [[ -f /etc/nftables.conf ]]; then
    cp /etc/nftables.conf "/etc/nftables.conf.backup.${TIMESTAMP}"
  fi
  
  cat > /etc/nftables.conf << 'EOF'
#!/usr/sbin/nft -f
include "/etc/nftables.d/logicorp.nft"
EOF

  service nftables enable 2>/dev/null
  service nftables restart 2>/dev/null
else
  sudo ./${RBACK_SH}.sh
fi

echo "Validate access (SSH over VPN, FTP for finance, database flow)."
