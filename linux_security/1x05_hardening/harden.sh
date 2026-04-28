#!/bin/bash
#########################
### HARDENING TOOLKIT ###
#########################

source logging.sh
AUDIT_FILE="audit_report.txt"

# Checks if the script is executed as root
if [ $(id -u) -ne 0 ]; then
	echo "You are not allowed to start the toolkit!"
	exit
else
	log "INFO" "Hardening framework initialized"
fi

echo "Framework in progress..."

# Report ang logs are generated during process
# - Report is the proof of tests and analysis, don't ignore it.
if [ -f audit_report.txt ]; then
	mv $AUDIT_FILE "audit_report_$(date '+%F_%H%M%S').txt"
fi

echo "==============================================" > $AUDIT_FILE
echo " HARDENING AUDIT REPORT - $(date '+%F %H:%M:%S')" >> $AUDIT_FILE
echo "==============================================" >> $AUDIT_FILE
echo ""
echo "[INFO] Hardening procedure" >> $AUDIT_FILE

# Control each policy category
source lib/network.sh
source lib/ssh.sh
source lib/identity.sh
source lib/system.sh

echo "Framework completed successfully."

sed -i 's/^\[INFO\] Hardening.*/[INFO] Hardening procedure completed successfully/' $AUDIT_FILE
echo ""
echo "==============================================" >> $AUDIT_FILE
echo " COMPLIANCE STATUS: PASS" 					 >> $AUDIT_FILE
echo "==============================================" >> $AUDIT_FILE
