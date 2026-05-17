#!/bin/bash
awk '{
	ip = $1
	status = $9
	if (status ~ /4[0-9][0-9]$/) { errors[ip]++ }
}
END {
	for (ip in errors) {
		if (errors[ip] > 5) { print "ALERT : IP " ip " is scanning us!" }
	}
}' "$1"

