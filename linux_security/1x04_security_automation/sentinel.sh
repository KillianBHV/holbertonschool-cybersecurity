#!/bin/bash
source ./sentinel.conf

if [ $? -ne 0 ]; then
	exit 1
fi

if [ -z $FILES_TO_WATCH ] || [ -z $SERVICES ]; then
	exit 1
fi

check_services () {
	for svc in "${SERVICES[@]}"; do
		pgrep -f "$svc" > /dev/null

		if [ $? -ne 0 ]; then
			eval "$svc" > /dev/null 2&>1

			if [ $? -ne 0 ]; then
				echo "ERROR: Unable to restart $svc"
			else
				echo "FIXED: Restarted service $svc"
			fi
		else
			echo "OK: $svc is running"
		fi
	done
}

check_integrity () {
	for file in "${FILES_TO_WATCH[@]}"; do
		gold_hash=$(md5sum "/var/backups/sentinel/${file##*/}.gold" | cut -d' ' -f1)
		file_hash=$(md5sum "$file" | cut -d' ' -f1)

		if [ $file_hash != $gold_hash ]; then
			cp "/var/backups/sentinel/${file##*/}.gold" "$file"
			echo "FIXED: Restored $file"
		else
			echo "OK: $file integrity verified"
		fi
	done
}

check_ports () {
	while read -r current_port; do
		present=0
		for p in "${ALLOWED_PORTS[@]}"; do
			if [[ "$p" == "$current_port" ]]; then
				$present=1
				break
			fi
		done

		if [[ $present -ne 1 ]]; then
			kill -SIGKILL $current_port
			echo "ALERT: Killed rogue process on port $current_port"
		fi
	done < <(ss -ltnpH 2>/dev/null | awk '{split($4,a,":"); print a[length(a)]}')
}

check_services
check_integrity
check_ports
