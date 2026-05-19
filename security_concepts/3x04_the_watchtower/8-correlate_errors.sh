#!/bin/bash
for ip in $(grep -E ' 4[0-9][0-9] ' "$1" | awk '{print $1}' | sort | uniq); do
    count=$(grep "$ip" "$1" | grep -E ' 4[0-9][0-9] ' | wc -l)

    if [ "$count" -gt 5 ]; then
        echo "ALERT: IP $ip is scanning us!"
    fi
done
