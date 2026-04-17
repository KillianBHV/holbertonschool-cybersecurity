#!/bin/bash
ip addr | grep -A 2 ^[0-9].*eth0 | tail -n 1 | tr -d ' ' | awk -F'/' '{print $1}' | sed 's/inet//'
