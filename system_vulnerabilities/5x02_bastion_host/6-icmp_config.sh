#!/bin/bash

HARDEN_FILE="/etc/sysctl.d/99-hardening.conf"

echo -e "=== Disabling IP Forwarding ==="

echo -e "\nDisabling broadcast ping response (Smurf prevention)..."
echo "  $(sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1)"

echo -e "\nKeeping unicast ping enabled for diagnostics."
echo "  $(sysctl -w net.ipv4.icmp_echo_ignore_all=0)"

echo -e "\nIgnoring bogus ICMP error responses..."
echo "  $(sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1)"

if [[ ! -f $HARDEN_FILE ]] || ! grep -q '^net\.ipv4\.icmp_echo_ignore_broadcasts=.*' "$HARDEN_FILE"; then
	echo 'net.ipv4.icmp_echo_ignore_broadcasts=1' >> $HARDEN_FILE
else
    sed -i 's/^net\.ipv4\.icmp_echo_ignore_broadcasts=.*/net.ipv4.icmp_echo_ignore_broadcasts=1/' "$HARDEN_FILE"
fi

if ! grep -q '^net\.ipv4\.icmp_echo_ignore_all=.*' "$HARDEN_FILE"; then
	echo 'net.ipv4.icmp_echo_ignore_all=0' >> $HARDEN_FILE
else
    sed -i 's/^net\.ipv4\.icmp_echo_ignore_all=.*/net.ipv4.icmp_echo_ignore_all=0/' "$HARDEN_FILE"
fi

if ! grep -q '^net\.ipv4\.icmp_ignore_bogus_error_responses=.*' "$HARDEN_FILE"; then
	echo 'net.ipv4.icmp_ignore_bogus_error_responses=1' >> $HARDEN_FILE
else
    sed -i 's/^net\.ipv4\.icmp_ignore_bogus_error_responses=.*/net.ipv4.icmp_ignore_bogus_error_responses=1/' "$HARDEN_FILE"
fi

echo -e "\nConfiguration saved to $HARDEN_FILE...\n"

echo -n "Broadcast ping: "
if [[ $(sysctl net.ipv4.icmp_echo_ignore_broadcasts | awk -F' = ' '{print $2}') -eq 1 ]]; then
	echo "DISABLED"
else
	echo "ENABLED"
fi

echo -n "Unicast ping: "
if [[ $(sysctl net.ipv4.icmp_echo_ignore_all | awk -F' = ' '{print $2}') -eq 0 ]]; then
	echo "ENABLED"
else
	echo "DISABLED"
fi

