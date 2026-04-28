#!/bin/bash

# SSH Hardening

source logging.sh
source config/harden.cfg
SSH_CONFIG_FILE="/etc/ssh/sshd_config"

# First generate a backup for data safety
cp "$SSH_CONFIG_FILE" "$SSH_CONFIG_FILE.backup"

# S-01) Disable password authentication
sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication no/' $SSH_CONFIG_FILE || echo 'PasswordAuthentication no' >> $SSH_CONFIG_FILE

# S-02) Block root login
sed -i 's/^.*PermitRootLogin.*/PermitRootLogin no/' $SSH_CONFIG_FILE || echo 'PermitRootLogin no' >> $SSH_CONFIG_FILE

# [BONUS] B-03) Allow SSH Key-Pair Connexions
sed -i 's/^.*PubkeyAuthentication.*/PubkeyAuthentication yes/' $SSH_CONFIG_FILE || echo 'PubkeyAuthentication no' >> $SSH_CONFIG_FILE

# Syntax Validation
sshd -t 2>/dev/null
if [ $? -eq 0 ]; then
	rm "$SSH_CONFIG_FILE.backup"

	log "SUCCESS" "SSH Configuration updated."
	audit "INFO" "SSH access applied."
else
	rm -rf $SSH_CONFIG_FILE
	mv "$SSH_CONFIG_FILE.backup" "$SSH_CONFIG_FILE"

	log "ERROR" "Configuration file does not seem to be valid. Backup Restored!"
	log "STOP" "For safety, exit toolkit. You can try to reload it."
	exit
fi
