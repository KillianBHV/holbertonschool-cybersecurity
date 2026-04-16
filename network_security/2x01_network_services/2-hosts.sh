#!/bin/bash
cat /etc/hosts | grep "localhost" | awk -F' ' '$0 ~ /\./ {print $1}'
