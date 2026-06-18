#!/bin/bash
echo -e "=== SSH Key Deployment ===\n"

echo "Target user: $(whoami)"

echo -e "\nCreating .ssh directory if needed..."

mkdir -p $HOME/.ssh
chmod 700 $HOME/.ssh
echo -e "  $HOME/.ssh: Created\n  Permissions: $(stat -c '%a' $HOME/.ssh)"

echo -e "\nAdding keys to authorized_keys..."

echo "  Key fingerprint: $(echo $1 | ssh-keygen -lf -)"
grep -qxF "$1" $HOME/.ssh/authorized_keys 2>/dev/null || echo "$1" >> $HOME/.ssh/authorized_keys
chmod 600 $HOME/.ssh/authorized_keys
echo "  Key added successfully"

echo -e "\nSetting permissions..."

chmod 600 $HOME/.ssh/authorized_keys
echo "  authorized_keys: 600"

echo -e "\nVerification:"
echo "  Key count in authorized_keys: $(cat $HOME/.ssh/authorized_keys | wc -l)"
echo -n "  Permission correct: "
if [ "$(stat -c '%a' $HOME/.ssh/authorized_keys)" == "600" ]; then
	echo "YES"
else
	echo "NO"
fi

echo -e "\nSSH key deployed.\nUser can now authenticate with this key."

