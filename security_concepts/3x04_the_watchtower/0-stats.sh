#!/bin/bash
echo "File: /var/log/auth.log - Lines:" $(cat "/var/log/auth.log" | wc -l)
echo "File: /var/log/syslog - Lines:" $(cat "/var/log/syslog" | wc -l)
echo "File: /var/log/kern.log - Lines:" $(cat "/var/log/kern.log" | wc -l)
