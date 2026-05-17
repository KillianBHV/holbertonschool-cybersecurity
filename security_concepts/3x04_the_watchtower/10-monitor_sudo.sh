#!/bin/bash
tail -f /var/log/auth.log | while read line; do
    if echo "$line" | grep -qiE "sudo.*authentication failure|authentication failure.*sudo"
    then
        echo "ALERT: Sudo violation detected!"
    fi
done
