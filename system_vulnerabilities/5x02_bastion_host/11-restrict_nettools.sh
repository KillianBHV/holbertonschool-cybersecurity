#!/bin/bash

echo -e "=== Network Tools Restriction ===\n"
VERIFIED_FILES=0

echo "Restricting access (root only)..."
packs=$(find /usr/bin /usr/sbin -type f -user root -perm -u=x | sort | grep -E "/(nc|netcat|nmap|tcpdump)$")
for p in ${packs[@]}; do
	past_perms=$(stat -c '%a' "$p")
	chmod 750 "$p"
	chown root:root "$p"

	current_perms=$(stat -c '%a' "$p")
	echo "  $p: 0$current_perms (was 0$past_perms)"
	VERIFIED_FILES=$(( VERIFIED_FILES + 1 ))
done

if [[ $VERIFIED_FILES -eq 0 ]]; then
	echo "  No file to restrict"
else
	echo -e "\nVerification:"
	for p in ${packs[@]}; do
		echo "  $p: $(stat -c '%A %U %G' "$p")"
	done
fi

echo -e "\nNetwork tools restricted to root."
echo "Regular users can no longer execute these binaries."

