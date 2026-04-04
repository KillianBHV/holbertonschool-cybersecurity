#!/bin/bash
while read -r username; do
	id $username > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		usermod -L -e 1 $username
		echo "User $username locked"
	else
		echo "User $username not found"
	fi
done < $1
