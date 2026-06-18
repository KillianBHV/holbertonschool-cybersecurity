#!/bin/bash
USER_NAME="$(whoami)"
SSH_DIR="/home/$USER_NAME/.ssh"
KEY_FILE="$SSH_DIR/id_ed25519"

echo -e "=== SSH Key Generation ===\n"

mkdir -p "$SSH_DIR"
echo -e "Generating ED25519 key pair...\n  Algorithm: ED25519 (recommended)"
echo -e "  Key file: $KEY_FILE\n"

ssh-keygen -q -t ed25519 -f "$SSH_DIR/id_ed25519" -C "$USER_NAME@$(hostname)"

echo -e "\nKey pair generated:"
echo -e "  Private key: $KEY_FILE\n  Public key: $KEY_FILE.pub"

echo -e "\nSetting permissions:"
chmod 600 "$KEY_FILE"
chmod 644 "$KEY_FILE.pub"

echo "  Private key: $(stat -c '%a' "$SSH_DIR/id_ed25519") (owner read/write only)"
echo "  Public key: $(stat -c '%a' "$SSH_DIR/id_ed25519.pub")"

echo -e "\nPublic key fingerprint:\n  $(ssh-keygen -lf "$SSH_DIR/id_ed25519.pub")"

echo -e "\nYour public key:"
cat "$SSH_DIR/id_ed25519.pub"

echo -e "\nNext step: Add this public key to target servers' authorized_keys" 

