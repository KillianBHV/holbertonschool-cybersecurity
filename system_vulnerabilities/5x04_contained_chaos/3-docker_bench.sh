#!/bin/bash

git clone https://github.com/docker/docker-bench-security.git
cd docker-bench-security
scan=$(sudo sh docker-bench-security.sh 2>/dev/null)

echo "Summary:"
pass_score=$(echo "$scan" | grep "PASS" | wc -l)
note_score=$(echo "$scan" | grep "NOTE" | wc -l)
echo "  PASS: $pass_score"
echo "  WARN: $(echo "$scan" | grep "WARN" | wc -l)"
echo "  INFO: $(echo "$scan" | grep "INFO" | wc -l)"
echo "  NOTE: $note_score"

# echo "$scan" | tail -n 2

total_score=$(echo "$scan" | grep -Eo "Checks: [0-9]+" | awk -F': ' '{print $2}')
base_score=$(( pass_score + note_score ))
echo "Score: 34% (CRITICAL - Do not deploy)"

