#!/bin/bash

echo -e "=== Package Security Audit ===\n"
PACKAGES=$(dpkg-query -W -f='${binary:Package}\t${binary:Summary}\n')

echo "Checking for development tools..."
DEV_TOOLS=("gcc" "g++" "make" "gdb")
DEV_FOUND=0
for package in "${DEV_TOOLS[@]}"; do
	result=$(echo "$PACKAGES" | grep "^$package" | head -1 | awk -F'\t' '{print $1 " (" $2 ")"}')
	if [[ ! -z $result ]]; then
		echo "  [FOUND] $result"
		DEV_FOUND=$(( DEV_FOUND + 1 ))
	fi
done

if [[ $DEV_FOUND -eq 0 ]]; then
	echo "  No package found."
fi

echo -e "\nChecking for network tools..."
NET_TOOLS=("netcat" "netcat-openbsd" "nmap" "tcpdump")
NET_FOUND=0
for package in "${NET_TOOLS[@]}"; do
	result=$(echo "$PACKAGES" | grep "^$package" | head -1 | awk -F'\t' '{print $1 " (" $2 ")"}')
	if [[ ! -z $result ]]; then
		echo "  [FOUND] $result"
		NET_FOUND=$(( NET_FOUND + 1 ))
	fi
done

if [[ $NET_FOUND -eq 0 ]]; then
	echo "  No package found."
fi

echo -e "\nChecking for remote access tools..."
REMOTE_ACCESS_TOOLS=("telnet")
REMOTE_FOUND=0
for package in "${REMOTE_ACCESS_TOOLS[@]}"; do
	result=$(echo "$PACKAGES" | grep "^$package" | head -1 | awk -F'\t' '{print $1 " (" $2 ")"}')
	if [[ ! -z $result ]]; then
		echo "  [FOUND] $result"
		REMOTE_FOUND=$(( REMOTE_FOUND + 1 ))
	fi
done

if [[ $REMOTE_FOUND -eq 0 ]]; then
	echo "  No package found."
fi

echo -e "\nSummary:"
echo "  Development tools: $DEV_FOUND found"
echo "  Network tools: $NET_FOUND found"
echo "  Remote access tools: $REMOTE_FOUND found"
echo -e "\nRecommendation: Review and remove unnecessary packages."

