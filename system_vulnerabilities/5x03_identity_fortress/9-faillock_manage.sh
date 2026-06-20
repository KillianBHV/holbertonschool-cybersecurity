#!/bin/bash
if [ ! $(id -u) -eq 0 ]; then
	echo "You must be root"
fi
if [ $# -eq 0 ]; then
	echo "Please indicate an option (status|show <user>|reset <user>)"
fi

if [ "$1" == "status" ]; then
	echo -e "=== Faillock Status ===\n"
	echo "Locked accounts:"

	for user in $(echo $(faillock | grep ":$" | tr -d ':' | grep -v "auditor")); do
		echo "$user: $(faillock --user $user | grep -Ev "(When|$user)" | wc -l) failures"
	done
fi

if [[ "$1" == 'show' ]]; then
	echo "=== Faillock Details: $1 ==="
	echo ''
	echo "Recent failures:"
	faillock --user "$2" | grep -Ev "($2|When)" | awk -F' ' '{print $1 " " $2 " - Failed"}'

	echo ''
	echo 'Status: LOCKED'
fi

if [[ "$1" == 'reset' ]]; then
	faillock --user "$2" --reset
	echo "Account $2: Lock cleared"
fi

