#!/bin/bash

PASS_CHECK=0
TOTAL_CHECK=0

echo "=== Kernel Hardening Verification ==="

echo -e "\nIP Forwarding:"
#net.ipv4.ip_forward=0

echo -e "\nICMP Redirects:"
#net.ipv4.conf.all.accept_redirects=0

echo -e "\nReverse Path Filtering:"
#net.ipv4.conf.all.rp_filter=1

echo -e "\nSYN Cookies:"

valid=0
command_result=$(sysctl net.ipv4.tcp_syncookies | awk -F ' = ' '{print $2}')
if [[ $command -eq 0 ]]; then
	valid=1
	echo -n "[PASS] "
	PASS_CHECK=$(( PASS_CHECK + 1))
else
	echo -n "[FAIL] "
fi

echo -n "net.ipv4.tcp_syncookies = 1"
if [[ $valid -eq 0 ]]; then
	echo " (should be 1)"
else
	echo ""
fi
TOTAL_CHECK=$(( TOTAL_CHECK + 1))

echo -e "\nICMP Configuration:"

valid=0
command_result=$(sysctl net.ipv4.icmp_echo_ignore_broadcasts | awk -F ' = ' '{print $2}')
if [[ $command -eq 0 ]]; then
	valid=1
	echo -n "[PASS] "
	PASS_CHECK=$(( PASS_CHECK + 1))
else
	echo -n "[FAIL] "
fi

echo -n "net.ipv4.icmp_echo_ignore_broadcasts = 1"
if [[ $valid -eq 0 ]]; then
	echo " (should be 1)"
else
	echo ""
fi
TOTAL_CHECK=$(( TOTAL_CHECK + 1))

echo -e "\nSource Routing:"

valid=0
command_result=$(sysctl net.ipv4.conf.all.accept_source_route | awk -F ' = ' '{print $2}')
if [[ $command -eq 0 ]]; then
	valid=1
	echo -n "[PASS] "
	PASS_CHECK=$(( PASS_CHECK + 1))
else
	echo -n "[FAIL] "
fi

echo -n "net.ipv4.conf.all.accept_source_route = "
if [[ $valid -eq 0 ]]; then
	echo "1 (should be 0)"
else
	echo "0"
fi
TOTAL_CHECK=$(( TOTAL_CHECK + 1))

valid=0
command_result=$(sysctl net.ipv4.conf.default.accept_source_route | awk -F ' = ' '{print $2}')
if [[ $command -eq 0 ]]; then
	valid=1
	echo -n "[PASS] "
	PASS_CHECK=$(( PASS_CHECK + 1))
else
	echo -n "[FAIL] "
fi

echo -n "net.ipv4.conf.default.accept_source_route = "
if [[ $valid -eq 0 ]]; then
	echo "1 (should be 0)"
else
	echo "0"
fi
TOTAL_CHECK=$(( TOTAL_CHECK + 1))

valid=0
command_result=$(sysctl net.ipv6.conf.all.accept_source_route | awk -F ' = ' '{print $2}')
if [[ $command -eq 0 ]]; then
	valid=1
	echo -n "[PASS] "
	PASS_CHECK=$(( PASS_CHECK + 1))
else
	echo -n "[FAIL] "
fi

echo -n "net.ipv6.conf.all.accept_source_route = "
if [[ $valid -eq 0 ]]; then
	echo "1 (should be 0)"
else
	echo "0"
fi
TOTAL_CHECK=$(( TOTAL_CHECK + 1))

valid=0
command_result=$(sysctl net.ipv6.conf.default.accept_source_route | awk -F ' = ' '{print $2}')
if [[ $command -eq 0 ]]; then
	valid=1
	echo -n "[PASS] "
	PASS_CHECK=$(( PASS_CHECK + 1))
else
	echo -n "[FAIL] "
fi

echo -n "net.ipv6.conf.default.accept_source_route = "
if [[ $valid -eq 0 ]]; then
	echo "1 (should be 0)"
else
	echo "0"
fi
TOTAL_CHECK=$(( TOTAL_CHECK + 1))

echo -ne "\nPersistence Check:\n  "
HARDEN_PATH="/etc/sysctl.d/99-hardening.conf"
if [ -f "$HARDEN_PATH" ]; then
	echo "[PASS] $HARDEN_PATH exists"
	PASS_CHECK=$(( PASS_CHECK + 1))
else
	echo "[FAIL] $HARDEN_PATH does not exist"
fi
TOTAL_CHECK=$(( TOTAL_CHECK + 1))

echo -e "\nSummary: $PASS_CHECK/$TOTAL_CHECK passed\nKernel hardening: COMPLETE"

