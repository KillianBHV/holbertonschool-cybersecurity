#!/bin/bash
GROUPS="docker disk shadow"

awk -F: '($3 >= 1000) {print $1}' "$1" | while read -r user; do
	users_groups=$(id -nG "$user" 2>/dev/null)
	for grp in $GROUPS; do
		echo $users_groups | grep -qw "$grp" && echo "$user:$grp"
	done
done
