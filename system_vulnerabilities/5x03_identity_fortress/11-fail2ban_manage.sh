#!/bin/bash
if [ $# -eq 0 ]; then
    echo "usage: You must specify a fail2ban-client argument"
    exit 1
fi

if [[ $1 == "status" ]]; then
	echo -e "=== fail2ban Status ===\n"
	echo "Service: $(systemctl status fail2ban | grep "Active" | awk -F' ' '{print $2}' | sed 's/active/Active/')"

	jails="$(fail2ban-client status | grep "Jail list" | awk -F':' '{print $2}' | xargs)"
	echo "Jails: $jails"

	for user in "$(echo "$jails" | tr -d ' ' | sed 's/,/ /g')"; do
		echo -e "\n[$user] Statistics:"
		fail2ban-client status $user | grep -E "(Currently|Total) banned" | sed 's/|- //g' | sed -E 's/:[[:space:]]+/: /g'
		echo -n "   " 
		fail2ban-client status $user | grep "Currently failed" | sed -E 's/\|[[:space:]]*\|- //g' | sed -E 's/:[[:space:]]+/: /g' 
	done
elif [[ "$1" == "banned" ]]; then
	echo "Jail: sshd"
	for ip in "$(fail2ban-client status sshd | grep "Banned IP list" | awk -F':' '{print $2}' | xargs)"; do
		echo "  $ip"
	done
elif [[ "$1" == "unban" ]]; then
	if [[ -z "$2" ]]; then
    	echo "usage: You must specify an ip to unban"
    	exit 1
	fi

	fail2ban-client set sshd unbanip $2 >/dev/null
	echo -e "IP $2 unbanned from jail sshd"
fi

