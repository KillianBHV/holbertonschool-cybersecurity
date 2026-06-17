#!/bin/bash

REPORT_FILE="/var/log/hardening/suid_audit.txt"
unknown_custom=0
echo -e "=== SUID/SGID Binary Audit ===\n" | tee -a "$REPORT_FILE"

echo "SUID Binaries (run as owner):" | tee -a "$REPORT_FILE"
list=$(find /usr/bin /usr/local/bin -type f -perm -u+s 2>/dev/null)
total_suid=$(echo "$list" | wc -l)
known_safes=("sudo" "su" "chsh" "chfn" "passwd")
review_needed=("umount" "at" "pkexec" "newgrp" "gpasswd" "mount")

for p in $list; do
	echo -ne "  $p\t$(stat -c '%U' $p)\t" | tee -a "$REPORT_FILE"

	found=0
	for s in ${known_safes[@]}; do
		pattern="$(echo "$p" | sed -E 's/^[[:space:]]+//' | awk -F' ' '{print $1}')"
		if [ "/usr/bin/$s" == $pattern -o "/usr/local/bin/$s" == $pattern ]; then
			found=1
			break
		fi
	done

	for s in ${review_needed[@]}; do
		pattern="$(echo "$p" | sed -E 's/^[[:space:]]+//' | awk -F' ' '{print $1}')"
		if [ "/usr/bin/$s" == $pattern -o "/usr/local/bin/$s" == $pattern ]; then
			found=2
			break
		fi
	done
	
	if [[ $found -eq 1 ]]; then
		echo "KNOWN SAFE" | tee -a "$REPORT_FILE"
	elif [[ $found -eq 2 ]]; then
		echo "REVIEW NEEDED" | tee -a "$REPORT_FILE"
	else
		echo "UNKNOWN - HIGH RISK" | tee -a "$REPORT_FILE"
		unknown_custom=$(( unknown_custom + 1 ))
	fi
done

echo -e "\nSGID Binaries (run as group):" | tee -a "$REPORT_FILE"
list=$(find /usr/bin /usr/local/bin -type f -perm -g+s 2>/dev/null)
total_sgid=$(echo "$list" | wc -l)
known_safes=("ssh-agent")
review_needed=("wall" "crontab")

for p in $list; do
	echo -ne "  $p\t$(stat -c '%G' $p)\t" | tee -a "$REPORT_FILE"

	found=0
	for s in ${known_safes[@]}; do
		pattern="$(echo "$p" | sed -E 's/^[[:space:]]+//' | awk -F' ' '{print $1}')"
		if [ "/usr/bin/$s" == $pattern -o "/usr/local/bin/$s" == $pattern ]; then
			found=1
			break
		fi
	done

	for s in ${review_needed[@]}; do
		pattern="$(echo "$p" | sed -E 's/^[[:space:]]+//' | awk -F' ' '{print $1}')"
		if [ "/usr/bin/$s" == $pattern -o "/usr/local/bin/$s" == $pattern ]; then
			found=2
			break
		fi
	done
	
	if [[ $found -eq 1 ]]; then
		echo "KNOWN SAFE" | tee -a "$REPORT_FILE"
	elif [[ $found -eq 2 ]]; then
		echo "REVIEW NEEDED" | tee -a "$REPORT_FILE"
	else
		echo "UNKNOWN - HIGH RISK" | tee -a "$REPORT_FILE"
		unknown_custom=$(( unknown_custom + 1 ))
	fi
done

echo -e "\nSummary:"
echo -e "  Total SUID: $total_suid\n  Total SGID: $total_sgid\n  Unknown/Custom: $unknown_custom (requires investigation)"

# write >> $REPORT_FILE
echo -e "\nFull report saved to: $REPORT_FILE"

