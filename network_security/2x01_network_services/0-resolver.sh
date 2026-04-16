#!/bin/bash
cat /etc/resolv.conf | grep "^nameserver" | awk -F' ' '$0 ~ /\./ {print $2}' | head -n 1
