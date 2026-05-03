#!/bin/bash

result=$(curl -x http://10.200.0.1:3128 -o /dev/null -s -w "%{http_code}" http://example.com/test.exe)
echo "$result"
[ "$result" = "403" ]
