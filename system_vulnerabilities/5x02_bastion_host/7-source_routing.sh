#!/bin/bash

HARDEN_FILE="/etc/sysctl.d/99-hardening.conf"

echo "=== Blocking Source Routing ==="

echo -e "\nDisabling source route acceptance..."
echo "  $(sysctl -w net.ipv4.conf.all.accept_source_route=0)"
echo "  $(sysctl -w net.ipv4.conf.default.accept_source_route=0)"
echo "  $(sysctl -w net.ipv6.conf.all.accept_source_route=0)"
echo "  $(sysctl -w net.ipv6.conf.default.accept_source_route=0)"

if [[ ! -f $HARDEN_FILE ]] || ! grep -q '^net\.ipv4\.conf\.all\.accept_source_route=.*' "$HARDEN_FILE"; then
	echo 'net.ipv4.conf.all.accept_source_route=0' >> $HARDEN_FILE
else
    sed -i 's/^net\.ipv4\.conf\.all\.accept_source_route=.*/net.ipv4.conf.all.accept_source_route=0/' "$HARDEN_FILE"
fi

if ! grep -q '^net\.ipv4\.conf\.default\.accept_source_route=.*' "$HARDEN_FILE"; then
	echo 'net.ipv4.conf.default.accept_source_route=0' >> $HARDEN_FILE
else
    sed -i 's/^net\.ipv4\.conf\.default\.accept_source_route=.*/net.ipv4.conf.default.accept_source_route=0/' "$HARDEN_FILE"
fi

if ! grep -q '^net\.ipv6\.conf\.all\.accept_source_route=.*' "$HARDEN_FILE"; then
	echo 'net.ipv6.conf.all.accept_source_route=0' >> $HARDEN_FILE
else
    sed -i 's/^net\.ipv6\.conf\.all\.accept_source_route=.*/net.ipv6.conf.all.accept_source_route=0/' "$HARDEN_FILE"
fi

if ! grep -q '^net\.ipv6\.conf\.default\.accept_source_route=.*' "$HARDEN_FILE"; then
	echo 'net.ipv6.conf.default.accept_source_route=0' >> $HARDEN_FILE
else
    sed -i 's/^net\.ipv6\.conf\.default\.accept_source_route=.*/net.ipv6.conf.default.accept_source_route=0/' "$HARDEN_FILE"
fi

echo -e "\nConfiguration saved to $HARDEN_FILE...\n\nSource-routed packets: BLOCKED"

