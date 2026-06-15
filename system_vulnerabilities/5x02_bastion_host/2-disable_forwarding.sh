#!/bin/bash
echo "=== Disabling IP Forwarding ==="

state_IPv4=$(sysctl net.ipv4.ip_forward)
state_IPv6=$(sysctl net.ipv6.conf.all.forwarding)

HARDEN_PATH="/etc/sysctl.d/99-hardening.conf"

echo -e "\nCurrent State:"
echo "  $state_IPv4"
echo -e "  $state_IPv6\n"

check_state=$(( $(echo "$state_IPv4" | awk -F' = ' '{print $2}') & $(echo "$state_IPv6" | awk -F' = ' '{print $2}') ))

if [[ $check_state -eq 1 ]]; then
	echo "Applying changes..."
	echo "  $(sysctl -w net.ipv4.ip_forward=0)"
	echo -e "  $(sysctl -w net.ipv6.conf.all.forwarding=0)\n"
fi

echo -e "Making persistent in $HARDEN_PATH..."

sed -i 's/^net\.ipv4\.ip_forward=.*/net.ipv4.ip_forward=0/' $HARDEN_PATH 2>/dev/null || echo "net.ipv4.ip_forward=0" >> $HARDEN_PATH
if ! grep -q '^net\.ipv6\.conf\.all\.forwarding=.*' "$HARDEN_PATH"; then
	echo 'net.ipv6.conf.all.forwarding=0' >> "$HARDEN_PATH"
else
	sed -i 's/^net\.ipv6\.conf\.all\.forwarding=.*/net.ipv6.conf.all.forwarding=0/' "$HARDEN_PATH"
fi

#/net.ipv6.conf.all.forwarding=0/' $HARDEN_PATH 2>/dev/null || echo "net.ipv6.all.conf.forwarding=0" >> $HARDEN_PATH

echo -e "\nVerification:"

state_IPv4=$(sysctl net.ipv4.ip_forward | awk -F' = ' '{print $2}')
state_IPv6=$(sysctl net.ipv6.conf.all.forwarding | awk -F' = ' '{print $2}')

echo -n "  IPv4 forwarding: "
if [[ $state_IPv4 -eq 0 ]]; then
	echo "DISABLED"
else
	echo "ENABLED"
fi

echo -n "  IPv6 forwarding: "
if [[ $state_IPv6 -eq 0 ]]; then
	echo "DISABLED"
else
	echo "ENABLED"
fi

