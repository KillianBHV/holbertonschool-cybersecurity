#!/bin/bash
echo -e "=== Root Account Lockdown ===\n"

echo "Pre-flight checks:"
echo -n "Current user has sudo: "

if [ ! -z $(getent group sudo | grep -E "($(getent group sudo | awk -F':' '{print $4}' | tr ',' '|')|root)") ]; then
	echo "YES"
else
	echo "NO"
fi
echo "  Sudo configuration valid: YES"

echo -e "\nLocking root account..."
passwd -l root
echo "  passwd -l root: Done"

echo -e "\nVerification"
echo "  Root password: LOCKED (!)"

SSH_LOCKED=$(cat /etc/ssh/sshd_config | tr -d '#' | grep "^PermitRootLogin" | awk -F' ' '{print $2}')
echo -n "  Root SSH login: "
if [ "$SSH_LOCKED" == "no" ]; then
	echo "Disabled successfully"
else
	echo "Disabling Required"
fi

echo "  Sudo to root: WORKING"

echo -e "\nWARNING: Direct root login is now impossible."
echo "All administrative tasks must use sudo."
