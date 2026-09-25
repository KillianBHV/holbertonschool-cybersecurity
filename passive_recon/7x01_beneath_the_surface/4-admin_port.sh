#!/bin/bash
nmap -sT -T2 --scan-delay 150ms --max-rate 20 --open -p49152-65535 admin.astralis-cloud.example | grep -E '^[0-9]+/' | awk -F/ '{print $1}'| head -1
