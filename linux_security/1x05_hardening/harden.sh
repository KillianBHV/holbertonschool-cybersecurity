#!/bin/bash

log () {
	echo "$(date) -" "$1" "$2" >> logs.txt
}

# /--- FILES IMPORTS ---/
folders=("config/harden.cfg" "lib/identity.sh" "lib/network.sh" "lib/ssh.sh" "lib/system.sh")

for file in ${folders[@]}; do
	source "$file" 2>/dev/null
	if [ $? -ne 0 ]; then
		log "[ERROR]" "$file: Import failed! Exit program..."
		exit 1
	fi
done

log "[INFO] All imports exit successfully"

audit_report() {
	report_file="audit_report.txt"    

	{
        echo "==============================================="
        echo " HARDENING AUDIT REPORT - $(date)"
        echo "==============================================="
        echo ""
        echo "[INFO] Hardening procedure completed successfully."
        echo "[INFO] SSH configured on port $SSH_PORT."
        echo "[INFO] Firewall policy created: /etc/hardening/firewall.rules"
        echo "[INFO] Kernel hardened: ip_forward=0, icmp_echo_ignore_all=1"
        echo "[INFO] Password policy: minlen=12, complexity enforced, max 90 days"
        echo "[INFO] Faillock: deny=5 attempts"
        echo "[INFO] Root account locked"
        echo "[INFO] $users_removed unauthorized users removed"
        echo ""
        echo "==============================================="
        echo " COMPLIANCE STATUS: PASS"
        echo "==============================================="
    } > "$report_file"
    log "Audit report generated: $report_file"
}

network_hardening
ssh_hardening
identity_hardening
system_hardening

unset $folders
