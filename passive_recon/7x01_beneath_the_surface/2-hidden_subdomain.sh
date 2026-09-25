#!/bin/bash
for c in $(grep -E "internal|backend|admin" ~/subdomains-top1million-5000.txt); do host "$c-svc.astralis-cloud.example" | awk -F' ' '!/^Host/ {print $1}'; sleep 0.2; done
