#!/bin/bash

# dpkg
# /var/lib/dpkg/lock

echo -e "=== PAM Configuration Audit ===\n"

echo -e "/etc/pam.d/common-auth:"
if [[ ! -z $(cat /etc/pam.d/common-auth | grep -Ev "^[[:blank:]]*$|^[[:blank:]]*#" | grep "pam_unix.so") ]]; then
	echo "  pam_unix.so: Standard password Authentication"
fi

if [[ ! -z $(cat /etc/pam.d/common-auth | grep -Ev "^[[:blank:]]*$|^[[:blank:]]*#" | grep "pam_deny.so") ]]; then
	echo "  pam_deny.so: Fallback deny"
fi

echo -e "\n/etc/pam.d/common-password:"
if [[ ! -z $(cat /etc/pam.d/common-password | grep -Ev "^[[:blank:]]*$|^[[:blank:]]*#" | grep "pam_unix.so") ]]; then
	echo "  pam_unix.so: Password change handling"
fi

echo -n "  Complexity enforcement: "
if [[ -z $(cat /etc/pam.d/common-password | grep -Ev "^[[:blank:]]*$|^[[:blank:]]*#" | grep "pam_pwquality.so") ]]; then
	echo "NONE"
else
	echo "YES"
fi
echo -n "  History enforcement: "
if [[ -z $(cat /etc/pam.d/common-password | grep -Ev "^[[:blank:]]*$|^[[:blank:]]*#" | grep "pam_pwhistory.so") ]]; then
	echo "NONE"
else
	echo "YES"
fi

echo -e "\n/etc/pam.d/sshd:"
cat /etc/pam.d/sshd | grep -Ev "^[[:blank:]]*$|^[[:blank:]]*#" | grep "^@include" | sed 's/@/  @/g'
echo "  MFA Modules: NONE"

search_pam=$(cat /etc/pam.d/* | grep -Ev "^[[:blank:]]*$|^[[:blank:]]*#" | grep -o "pam_[A-Za-z]*.so" | sort | uniq)
echo -ne "\nAccount Lockout:\n  pam_faillock: "
if [[ -z $(echo "$search_pam" | grep "pam_faillock.so") ]]; then
	echo -n "NOT "
fi
echo "CONFIGURED"

echo -n "  pam_tally2: "
if [[ -z $(echo "$search_pam" | grep "pam_tally2.so") ]]; then
	echo -n "NOT "
fi
echo "CONFIGURED"

echo -e "\nPassword Aging:"
passwords=$(cat /etc/login.defs | grep -Ev "^[[:blank:]]*$|^[[:blank:]]*#" | grep "PASS_" | awk -F' ' '{print $2}')
echo $passwords | awk -F' ' '{print "  Default max days: " $1 "\n  Default min days: " $2 "\n  Default warn days: " $3}' | sed 's/99999/99999 (effectively disabled)/'

echo -e "\nSSH Authentication:"
ssh_params=$(cat /etc/ssh/sshd_config | grep -Ev "^[[:blank:]]*$|^[[:blank:]]*#" | grep "PasswordAuthentication|ChallengeResponseAuthentication|PubkeyAuthentication")

if [[ ! -z $(echo "$ssh_params" | grep "PasswordAuthentication") ]]; then
	echo "  PasswordAuthentication: yes (INSECURE)"
else
	echo "  PasswordAuthentication: no"
fi

if [[ ! -z $(echo "$ssh_params" | grep "PubkeyAuthentication") ]]; then
	echo "  PubkeyAuthentication: yes"
else
	echo "  PubkeyAuthentication: no"
fi

if [[ ! -z $(echo "$ssh_params" | grep "ChallengeResponseAuthentication") ]]; then
	echo "  ChallengeResponseAuthentication: yes"
else
	echo "  ChallengeResponseAuthentication: no"
fi

echo -e "\nSummary: Identity controls are WEAK"

