# An efficient tool always log any actions, mostly sensitive ones
log () {
	echo "$(date '+%F %H:%M:%S')	[$1] $2" >> /var/log/hardening.log
}
audit () {
	echo "[$1] $2" >> audit_report.txt
}
