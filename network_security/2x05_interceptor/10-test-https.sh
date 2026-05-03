#!/bin/bash
curl -x http://10.200.0.1:3128 -k -o /dev/null -s -w "%{http_code}" https://malware.com
