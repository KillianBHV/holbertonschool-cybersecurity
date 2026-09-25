#!/bin/bash
openssl s_client -connect portal.astralis-cloud.example:443 -servername astralis-cloud.example </dev/null 2>/dev/null | openssl x509 -noout -ext subjectAltName | awk -F, '/DNS:/ {print $3}' | sed -E 's/[[:space:]]|\r//'
