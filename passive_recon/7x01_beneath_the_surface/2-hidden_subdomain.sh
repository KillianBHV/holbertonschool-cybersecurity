#!/bin/bash
gobuster -m dns -u astralis-cloud.example -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt -t 4 2>/dev/null | awk '/^Found/ {print $2}' | grep -E "(internal|backend|admin)" | head -n1
