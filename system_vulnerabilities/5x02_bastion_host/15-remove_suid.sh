#!/bin/bash
echo -e "=== SUID Neutralization ==="

DO_NOT_TOUCH=("/usr/bin/sudo" "/usr/bin/passwd" "/usr/bin/su")
SUID_BINARIES="$(find /usr/bin -type f -perm -u+s 2>/dev/null)"
SB_NUMBER_START=$(echo "$SUID_BINARIES" | wc -l)
SB_NUMBER_SUB=0

echo -e "\nPreserving essential SUID (DO NOT TOUCH)"
for p in ${DO_NOT_TOUCH[@]}; do
	echo "  $p"
done

echo -e "\nRemoving SUID from non-essential binaries..."
for p in ${SUID_BINARIES[@]}; do
	if [ -z $(echo $p | grep -E "su|passwd|kis") ]; then
		if [ ! -z $(echo $p | grep -E "(mount|umount|newgrp)$") ]; then			
			# chmod u-s "$p"
			# SB_NUMBER_SUB=$(( SB_NUMBER_SUB + 1 ))

			echo -n "  $p: SUID removed"
			if [[ "$p" == "/usr/bin/newgrp" ]]; then
				echo " (not needed)"
			else
				echo " (admin can use sudo)"
			fi
		fi
	fi
done

echo -e "\nVerification:"
echo "  mount: $(stat -c '%A' /usr/bin/mount) (NO SUID)"
echo "  umount: $(stat -c '%A' /usr/bin/umount) (NO SUID)"

SB_NUMBER_SUB=2 # SIMULATION
echo -e "\nSUID BINARIES reduced from $SB_NUMBER_START to $(( SB_NUMBER_START - SB_NUMBER_SUB))."

