#!/bin/bash
mkdir -p /etc/squid/ssl_cert
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -keyout /etc/squid/ssl_cert/myCA.pem \
    -out /etc/squid/ssl_cert/myCA.pem \
    -subj "/CN=SquidCA"
/usr/lib/squid/security_file_certgen -c -s /var/lib/ssl_db -M 4MB
