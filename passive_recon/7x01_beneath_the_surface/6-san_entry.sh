#!/bin/bash
openssl s_client -connect portal.astralis-cloud.example:443 </dev/null 2>/dev/null | openssl x509 -noout -ext subjectAltName | awk -F, '/DNS:/ {sub(/DNS:/,"",$3); print $3}' | sed -E 's/[[:space:]]|\r//' | grep "mgmt" | head -1
