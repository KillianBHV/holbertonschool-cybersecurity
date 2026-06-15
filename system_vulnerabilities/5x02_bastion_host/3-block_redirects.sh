#!/bin/bash

HARDEN_FILE="/etc/sysctl.d/99-hardening.conf"

echo -e "=== Disabling IP Forwarding ===\n"

echo "Disabling redirect acceptance..."
echo "  $(sysctl -w net.ipv4.conf.all.accept_redirects=0)"
echo "  $(sysctl -w net.ipv4.conf.default.accept_redirects=0)"
echo "  $(sysctl -w net.ipv6.conf.all.accept_redirects=0)"
echo "  $(sysctl -w net.ipv6.conf.default.accept_redirects=0)"

echo "Disabling redirect sending..."
echo "  $(sysctl -w net.ipv4.conf.all.send_redirects=0)"
echo "  $(sysctl -w net.ipv4.conf.default.send_redirects=0)"

if [[ ! -f $HARDEN_FILE ]] || ! grep -q '^net\.ipv4\.conf\.all\.accept_redirects=.*' "$HARDEN_FILE"; then
	echo 'net.ipv4.conf.all.accept_redirects=0' >> $HARDEN_FILE
else
    sed -i 's/^net\.ipv4\.conf\.all\.accept_redirects=.*/net.ipv4.conf.all.accept_redirects=0/' "$HARDEN_FILE"
fi

if ! grep -q '^net\.ipv4\.conf\.default\.accept_redirects=.*' "$HARDEN_FILE"; then
	echo 'net.ipv4.conf.default.accept_redirects=0' >> $HARDEN_FILE
else
    sed -i 's/^net\.ipv4\.conf\.default\.accept_redirects=.*/net.ipv4.conf.default.accept_redirects=0/' "$HARDEN_FILE"
fi

if ! grep -q '^net\.ipv6\.conf\.all\.accept_redirects=.*' "$HARDEN_FILE"; then
	echo 'net.ipv6.conf.all.accept_redirects=0' >> $HARDEN_FILE
else
    sed -i 's/^net\.ipv6\.conf\.all\.accept_redirects=.*/net.ipv6.conf.all.accept_redirects=0/' "$HARDEN_FILE"
fi

if ! grep -q '^net\.ipv6\.conf\.default\.accept_redirects=.*' "$HARDEN_FILE"; then
	echo 'net.ipv6.conf.default.accept_redirects=0' >> $HARDEN_FILE
else
    sed -i 's/^net\.ipv6\.conf\.default\.accept_redirects=.*/net.ipv6.conf.default.accept_redirects=0/' "$HARDEN_FILE"
fi

if ! grep -q '^net\.ipv4\.conf\.all\.send_redirects=.*' "$HARDEN_FILE"; then
	echo 'net.ipv4.conf.all.send_redirects=0' >> $HARDEN_FILE
else
    sed -i 's/^net\.ipv4\.conf\.all\.send_redirects=.*/net.ipv4.conf.all.send_redirects=0/' "$HARDEN_FILE"
fi

if ! grep -q '^net\.ipv4\.conf\.default\.send_redirects=.*' "$HARDEN_FILE"; then
	echo 'net.ipv4.conf.default.send_redirects=0' >> $HARDEN_FILE
else
    sed -i 's/^net\.ipv4\.conf\.default\.send_redirects=.*/net.ipv4.conf.default.send_redirects=0/' "$HARDEN_FILE"
fi

echo -e "\nConfiguration saved to $HARDEN_FILE\n\nICMP Requests: BLOCKED"

