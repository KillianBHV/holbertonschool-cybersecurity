#!/bin/bash

SSH_CONFIG_FILE="/etc/ssh/sshd_config"

stop_service() {
  if [[ "$(id -u)" -eq 0 ]]; then
    echo "Desired disabling service: ${svc}"
    service "$1" stop 2>/dev/null
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

test_ssh() {
  if grep -qE "^[#[:space:]]*$1[[:space:]]+" "$SSH_CONFIG_FILE"; then
    sed -i -E "s/^[#[:space:]]*$1[[:space:]].*/$1 $2/g" "$SSH_CONFIG_FILE"
  else
    echo "$1 $2" >> "$SSH_CONFIG_FILE"
  fi
}
test_ssh "PermitRootLogin" "no"
test_ssh "PasswordAuthentication" "no"
test_ssh "PubkeyAuthentication" "yes"
test_ssh "AllowUsers" "student"
