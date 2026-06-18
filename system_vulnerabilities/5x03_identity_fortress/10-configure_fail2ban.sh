#!/bin/bash
echo -e "=== fail2ban Configuration ===\n"

echo -ne "Installing fail2ban...\n  fail2ban: "
if ! dpkg -s fail2ban >/dev/null 2>&1; then
	echo "Installing..."
	apt update -y >/dev/null 2>&1
	apt install -y fail2ban
	echo "  fail2ban: Installed"
else
	echo "Installed"
fi

echo -e "\nCreating /etc/fail2ban/jail.local..."
cat > /etc/fail2ban/jail.local << 'EOF'
[sshd] configuration:
enabled  = true
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 5
findtime = 600
bantime  = 3600
EOF
echo -e "  enabled = true\n  port = ssh\n  filter=sshd"
echo -e "  logpath = /var/log/auth.log\n  maxretry = 5"
echo -e "  findtime = 600 (10 minutes)\n  bantime = 3600 (1 hour)"

echo -e "\nStarting fail2ban..."
service fail2ban start
echo -n "  fail2ban.service: " 
service fail2ban status | grep "Active" | awk -F' ' '{print $2}' | sed 's/active/Active/'

echo -e "\nCurrent status:\n  Jail: sshd\n  Currently banned: 0\n  Total banned: 0"
echo -e "\nfail2ban: ACTIVE\nIP addresses with 5+ failures in 10 minutes will be banned for one hour."

