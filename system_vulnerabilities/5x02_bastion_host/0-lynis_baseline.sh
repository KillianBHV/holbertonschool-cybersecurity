#!/bin/bash

lynis_scan=$(lynis audit system 2>/dev/null)
header=$(echo "$lynis_scan" | grep -E "(Hardening index|Tests performed|Warnings|Suggestions)" | sed -E 's/([[:space:]]+:[[:space:]]+|[[:space:]]+\()/: /' | sed 's/)://')
current_date=$(date +%Y%m%d)
log_path="/var/log/hardening/baseline-$current_date.txt"
criticals=$(echo "$lynis_scan" | sed -E 's/(\x1B\[[0-9;]*[A-Za-z]|^[[:space:]]+)//g' | grep -E '^![[:space:]]+' | sed -E 's/^![[:space:]]+/  [WARNING] /g')

mkdir -p /var/log/hardening
echo -e "\nRunning Lynis audit...\n"

echo "$header" | grep "Hardening"
echo "$header" | grep "Tests"
echo "$header" | grep "Warnings"
echo "$header" | grep "Suggestions"

echo -e "\nCritical Findings:"
echo "$criticals"

echo "$lynis_scan" > $log_path
echo -e "\nBaseline saved to: $log_path"

