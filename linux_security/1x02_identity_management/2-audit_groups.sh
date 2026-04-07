#!/bin/bash
GROUPS="docker disk shadow"

declare -A GID_TO_GROUPS
while IFS=: read -r name _ gid _; do
	for target in $GROUPS; do
		if [ "$name" = "$target" ]; then
			GID_TO_GROUPS["$gid"]="$name"
		fi
	done
done < <(getent group)

awk -F: '($3 >= 1000) {print $1 ":" $4}' "$1" | while IFS=: read -r user gid; do
	if [ -n "${GID_TO_GROUPS[$gid]}" ]; then
		echo "$user:${GID_TO_GROUPS[$gid]}"
	fi

	for grp in $GROUPS; do
		members=$(getent group "$grp" | cut -d':' -f4)
		echo "$members" | tr ',' '\n' | grep -qx "$user" \
			echo "$user:$grp"		
	done
done | sort -u
