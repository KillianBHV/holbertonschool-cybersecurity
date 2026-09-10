#!/bin/bash
nmap -sn -T2 -PE -PS22,80,443 -PA22,80,443 -PU53,67,68 --scan-delay 150ms 10.10.10.0/24
