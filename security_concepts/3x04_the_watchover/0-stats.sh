#!/bin/bash
files=("auth.log" "syslog" "kern.log")
for file in "${files[@]}"; do echo "File: /var/log/$file - Lines:" $(cat "/var/log/$file" | wc -l); done

