#!/bin/bash
network_hardening () {
	mkdir -p /etc/hardening    
	cat > /etc/hardening/firewall.rules << EOF
		DEFAULT_INPUT=deny
		DEFAULT_OUTPUT=allow
		ALLOW_TCP=$SSH_PORT
		ALLOW_TCP=80
		ALLOW_TCP=443
EOF
    
	grep -q '^net.ipv4.ip_forward=0' /etc/sysctl.conf || echo 'net.ipv4.ip_forward=0' >> /etc/sysctl.conf
    grep -q '^net.ipv4.icmp_echo_ignore_all=1' /etc/sysctl.conf || echo 'net.ipv4.icmp_echo_ignore_all=1' >> /etc/sysctl.conf
    
	log "Network Hardening: N-01, N-02, N-03 complete"
}
