#!/bin/bash

result=$(curl -x http://10.200.0.1:3128 -o /dev/null -s -w "%{http_code}" http://malware.com)
echo "$result"
[ "$result" = "403" ]
