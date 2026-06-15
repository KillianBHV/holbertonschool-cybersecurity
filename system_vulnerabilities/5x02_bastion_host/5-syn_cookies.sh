#!/bin/bash

HARDEN_PATH="/etc/sysctl.d/99-hardening.conf"

echo -e "=== Enabling SYN cookies ===\n"

current_state=$(sysctl net.ipv4.tcp_syncookies)
echo "Current state:"
echo "  $current_state"

if [[ $(echo "$current_state" | awk -F' = ' '{print $2}') -eq 0 ]]; then
	echo "Enabling SYN cookies..."
	echo "  $(sysctl -w net.ipv4.tcp_syncookies=1)"
fi

if [[ ! -f $HARDEN_PATH ]] || ! grep -q '^net\.ipv4\.tcp_syncookies=.*' "$HARDEN_PATH"; then
	echo 'net.ipv4.tcp_syncookies=0' >> "$HARDEN_PATH"
else
	sed -i 's/^net\.ipv4\.tcp_syncookies=.*/net.ipv4.tcp_syncookies=1/' "$HARDEN_PATH"
fi

echo -e "Making persistent in $HARDEN_PATH...\n"

current_state=$(sysctl net.ipv4.tcp_syncookies)
echo -n "SYN flood protection: "
if [[ $(echo "$current_state" | awk -F' = ' '{print $2}') -eq 1 ]]; then
	echo "ENABLED"
else
	echo "DISABLED"
fi

