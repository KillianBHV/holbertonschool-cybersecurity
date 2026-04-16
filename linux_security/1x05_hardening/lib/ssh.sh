#!/bin/bash
ssh_hardening () {
	local conf="/etc/ssh/sshd_config"

	sed -i "s/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/" "$conf"
	sed -i "s/^#*PasswordAuthentication.*/PasswordAuthentication no/" "$conf"  
	sed -i "s/^#*PermitRootLogin.*/PermitRootLogin no/" "$conf"

	log "[INFO]" "SSH Hardening: S1, S2 complete (no root; keys only allowed)"
}
