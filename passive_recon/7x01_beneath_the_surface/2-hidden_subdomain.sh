#!/bin/bash
for w in $(grep -E "internal|backend|admin" /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt); do sub="$w.astralis-cloud.example"; if [ -n "$(dig +short "$sub")" ]; then echo "$sub"; break; fi; sleep 0.2; done
