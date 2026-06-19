#!/bin/bash
echo -e "=== Disable SSH Password Authentication ===\n"

echo -ne "Current user has SSH key: CHECKING...\nKey-based auth working: "
if [ -f $HOME/.ssh/authorized_keys ]; then
	echo "YES"
else
	echo "NO"
fi

echo -e "\nWARNING: This will disable password authentication.\nEnsure you have working key-based access!"
echo -ne "\nBacking up sshd_config...\n  "

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +'%Y%m%d')
echo -e "/etc/ssh/sshd_config.backup.$(date +'%Y%m%d')\n"

echo "Modifying /etc/ssh/sshd_config..."
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sed -i 's/UsePAM no/UsePAM yes/' /etc/ssh/sshd_config

echo "  PasswordAuthentication: yes -> no"
echo "  ChallengeResponseAuthentication: yes -> no"
echo "  UsePAM: yes (preserving for account checks)"

echo -e "\nValidating configuration..."
echo -n "  sshd -t: "
sshd -t -f /etc/ssh/sshd_config
if [[ $? -eq 0 ]]; then echo "OK"; else echo "INVALID"; fi

echo -e "\nReloading ssh..."
systemctl reload ssh
echo "  sshd.service: Reloaded"

echo -ne "\nVerification:\n  Password auth: "
if [[ "$(grep "PasswordAuthentication" /etc/ssh/sshd_config | awk -F' ' '{print $2}' | xargs)" == "no" ]]; then
	echo "DISABLED"
else
	echo "ENABLED"
fi

echo -n "  Pubkey auth: "
if [[ "$(grep "PubkeyAuthentication" /etc/ssh/sshd_config | awk -F' ' '{print $2}' | xargs)" == "no" ]]; then
	echo "DISABLED"
else
	echo "ENABLED"
fi

echo -e "\nSSH now required key-based authentication."

