#!/usr/bin/env bash

_ROOT=1
if [[ "${EUID}" -ne 0 ]]; then
  _ROOT=0
  echo "Non-root: generating WireGuard configs and keys locally"
fi

WG_IF="${WG_IF:-wg0}"
WG_PORT="${WG_PORT:-51820}"
WG_NET="${WG_NET:-10.30.0.0/24}"
WG_SERVER_IP="${WG_SERVER_IP:-10.30.0.1/24}"
WG_ENDPOINT="${WG_ENDPOINT:-15.137.114.45}"
WG_PATH="/etc/wireguard"
CLIENT_PATH="${WG_PATH}/clients"
FINANCE_FTP_TARGET="${FINANCE_FTP_TARGET:-10.42.191.56}"
PASSIVE_MIN="${PASSIVE_MIN:-39000}"
PASSIVE_MAX="${PASSIVE_MAX:-41000}"

if [[ "${_ROOT}" -eq 0 ]]; then
  WG_PATH="${PWD}/artifacts/wireguard"
  CLIENT_PATH="${WG_PATH}/clients"
fi

mkdir -p "${WG_PATH}" "${CLIENT_PATH}"

WG_AVAILABLE=1
echo "[+] Installing wireguard packages"
apt-get update -y && apt-get install -y wireguard wireguard-tools qrencode

key_placeholder() {
  tr -dc 'A-Za-z0-9' </dev/urandom | head -c 44
}
echo "PLACEHOLDER_SERVER_PRIVATE_KEY_$(key_placeholder)" > "${WG_PATH}/server_private.key"
echo "PLACEHOLDER_SERVER_public_cl_KEY_$(key_placeholder)" > "${WG_PATH}/server_public_cl.key"

SERVER_PRIV="$(cat "${WG_PATH}/server_private.key")"
SERVER_PUB="$(cat "${WG_PATH}/server_public_cl.key")"

# Generate two baseline clients: admin and finance
create_client() {
  name="$1"
  ip="$2"
  allowed_ips="$3"
  priv_file="${CLIENT_PATH}/${name}.key"
  pub_file="${CLIENT_PATH}/${name}.pub"
  conf_file="${CLIENT_PATH}/${name}.conf"

  echo "PLACEHOLDER_${name}_PRIVATE_KEY_$(key_placeholder)" > "${priv_file}"
  echo "PLACEHOLDER_${name}_public_KEY_$(key_placeholder)" > "${pub_file}"
  
  private_cl="$(cat "${priv_file}")"
  public_cl="$(cat "${pub_file}")"

  cat > "${conf_file}" << 'EOF'
[Interface]
PrivateKey = ${private_cl}
Address = ${ip}/32
DNS = 8.8.8.8

[Peer]
publicKey = ${SERVER_PUB}
Endpoint = ${WG_ENDPOINT}:${WG_PORT}
AllowedIPs = ${allowed_ips}
PersistentKeepalive = 25
EOF

  echo "${name}:${ip}:${public_cl}"
}

ADMIN_META="$(create_client admin1 10.30.0.5 "${WG_NET}")"
FIN_META="$(create_client finance1 10.30.0.15 "${FINANCE_FTP_TARGET}/32")"

ADMIN_PUB="$(echo "${ADMIN_META}" | awk -F: '{print $3}')"
FIN_PUB="$(echo "${FIN_META}" | awk -F: '{print $3}')"

cat > "${WG_PATH}/${WG_IF}.conf" << 'EOF'
[Interface]
Address = ${WG_SERVER_IP}
ListenPort = ${WG_PORT}
PrivateKey = ${SERVER_PRIV}
SaveConfig = true
PostUp = sysctl -w net.ipv4.ip_forward=1
PostDown = true

[Peer]
publicKey = ${ADMIN_PUB}
AllowedIPs = 10.30.0.5/32

[Peer]
# Finance client (FTP over VPN)
publicKey = ${FIN_PUB}
AllowedIPs = 10.30.0.15/32
EOF

sudo mkdir -p /etc/wireguard/clients
sudo cp "${WG_DIR}/${WG_IF}.conf" /etc/wireguard/${WG_IF}.conf
sudo cp ${CLIENT_DIR}/*.conf /etc/wireguard/clients/
chmod 600 "${WG_PATH}"/*.key "${WG_PATH}/${WG_IF}.conf" "${CLIENT_PATH}"/*.key

wg-quick down "${WG_IF}"
wg-quick up "${WG_IF}"

echo "WireGuard server public key: ${SERVER_PUB}"
echo "[+] Generated client configs:"
echo "   ${CLIENT_PATH}/admin1.conf"
echo "   ${CLIENT_PATH}/finance1.conf"
if [[ "${WG_AVAILABLE}" -eq 0 ]]; then
  echo "[!] NOTE: Placeholder keys were used; regenerate real keys with wg when root access is available."
fi
echo
echo "[!] Update endpoint in client configs if needed: ${WG_ENDPOINT}:${WG_PORT}"
echo "[!] Finance FTP over VPN target: ${FINANCE_FTP_TARGET}:21 (passive ${PASSIVE_MIN}-${PASSIVE_MAX})"
