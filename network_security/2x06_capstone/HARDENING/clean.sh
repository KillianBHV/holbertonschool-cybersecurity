#!/bin/bash

SSH_CONFIG_FILE="/etc/ssh/sshd_config"

# --- Disable unnecessary services ---
stop_service() {
  svc="$1"
  if [[ "${ROOT_MODE}" -eq 0 ]]; then
    echo "Desired disabling service: ${svc}"
    service "${svc}" stop 2>/dev/null
    service "${mask}" stop 2>/dev/null
  fi
}
stop_service "telnet"
stop_service "ttyd"

# --- Harden SSH ---
# Backup sshd_config
cp "$SSH_CONFIG_FILE" "$SSH_CONFIG_FILE.backup"
# Disable root login
# Disable password authentication
sed -i 's/^.*PermitRootLogin.*/PermitRootLogin no/' $SSH_CONFIG_FILE || echo 'PermitRootLogin no' >> $SSH_CONFIG_FILE
sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication no/' $SSH_CONFIG_FILE || echo 'PasswordAuthentication no' >> $SSH_CONFIG_FILE
# Enable public-key authentication
sed -i 's/^.*PubkeyAuthentication.*/PubkeyAuthentication yes/' $SSH_CONFIG_FILE || echo 'PubkeyAuthentication no' >> $SSH_CONFIG_FILE

test_sshd() {
  key="$1"
  value="$2"
  if grep -qE "^[#[:space:]]*${key}[[:space:]]+" "${SSH_CONFIG_FILE}"; then
    sed -i -E "s/^[#[:space:]]*${key}[[:space:]].*/${key} ${value}/g" "${SSH_CONFIG_FILE}"
  else
    echo "${key} ${value}" >> "${SSH_CONFIG_FILE}"
  fi
}
test_sshd "PermitRootLogin" "no"
test_sshd "PasswordAuthentication" "no"
test_sshd "PubkeyAuthentication" "yes"
test_sshd "AllowUsers" "student"
