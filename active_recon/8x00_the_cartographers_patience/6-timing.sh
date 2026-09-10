#!/bin/bash
nmap -Pn --scan-delay 3s --max-rate 1 -p80,8443 10.10.10.20
