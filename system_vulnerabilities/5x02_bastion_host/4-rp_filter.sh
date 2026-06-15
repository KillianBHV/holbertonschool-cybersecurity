#!/bin/bash

HARDEN_FILE="/etc/sysctl.d/99-hardening.conf"

echo -e "=== Enabling Reverse Path Filtering ===\n"

echo "Setting strict mode (1) for all interfaces..."
echo "  $(sysctl -w net.ipv4.conf.all.rp_filter=1)"
echo "  $(sysctl -w net.ipv4.conf.default.rp_filter=1)"

if [[ ! -f $HARDEN_FILE ]] || ! grep -q '^net\.ipv4\.conf\.all\.rp_filter=.*' "$HARDEN_FILE"; then
	echo 'net.ipv4.conf.all.rp_filter=1' >> $HARDEN_FILE
else
    sed -i 's/^net\.ipv4\.conf\.all\.rp_filter=.*/net.ipv4.conf.all.rp_filter=1/' "$HARDEN_FILE"
fi

if ! grep -q '^net\.ipv4\.conf\.default\.rp_filter=.*' "$HARDEN_FILE"; then
	echo 'net.ipv4.conf.default.rp_filter=1' >> $HARDEN_FILE
else
    sed -i 's/^net\.ipv4\.conf\.default\.rp_filter=.*/net.ipv4.conf.default.rp_filter=1/' "$HARDEN_FILE"
fi

echo -e "\nConfiguration saved to /etc/sysctl.d/99-hardening.conf"
echo -e "\nReverse path filtering: STRICT MODE"
echo "Spoofed packets will be dropped."

