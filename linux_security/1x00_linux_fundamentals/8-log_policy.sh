#!/bin/bash
mkdir -p $1
chown root:$2 $1
chmod g+s,u+rwx,g+rx,o-rwx $1
cat << EOF > /etc/logrotate.d/app
$1/*.log {
	daily
	missingok
	rotate 7
	compress
	delaycompress
	notifempty
	create 0640 root $2
}
EOF
