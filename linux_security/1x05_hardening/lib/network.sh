#!/bin/bash

# Network Hardening

SYSCTL_CONF="/etc/sysctl.conf"
FIREWALL_RULES="/etc/hardening/firewall.rules"
source logging.sh
source config/harden.cfg

mkdir -p /etc/hardening

# N-01) Firewall: Allow Outgoing / Deny Incoming
# N-02) Only SSH and HTTP/HTTPS
cat > $FIREWALL_RULES << EOF
DEFAULT_INPUT=deny
DEFAULT_OUTPUT=allow
ALLOW_SSH=$PORT_NUMBER_SSH
ALLOW_HTTP=80
ALLOW_HTTPS=443
EOF

# N-03) ICMP rejects ICMP requests
echo "# Disable IP forwarding" > $SYSCTL_CONF 
echo "net.ipv4.ip_forward = 0" >> $SYSCTL_CONF

echo "# Ignore ICMP Echo requests" >> $SYSCTL_CONF
echo "net.ipv4.icmp_echo_ignore_all = 1" >> $SYSCTL_CONF

log "SUCCESS" "Network Policies OK."
audit "INFO" "SSH configured on port $PORT_NUMBER_SSH."
audit "INFO" "Firewall policy created: ports $PORT_NUMBER_SSH, 80, 443 ALLOWED."
