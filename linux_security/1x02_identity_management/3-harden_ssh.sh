#!/bin/bash
sed -i -E 's/^[[:space:]]*#?PermitRootLogin[[:space:]]+.*/PermitRootLogin no/g' "$1"
sed -i -E 's/^[[:space:]]*#?PasswordAuthentication[[:space:]]+.*/PasswordAuthentication no/g' "$1"
sed -i -E 's/^[[:space:]]*#?PubkeyAuthentication[[:space:]]+.*/PubkeyAuthentication yes/g' "$1"

sshd -t > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
	/etc/init.d/ssh reload > /dev/null 2>&1	
fi
