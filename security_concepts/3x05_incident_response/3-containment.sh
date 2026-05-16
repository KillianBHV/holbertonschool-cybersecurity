#!/bin/bash
iptables -A INPUT -s "$1" -j DROP
iptables -D OUTPUT -d "$1" -j DROP
kill -STOP "$2"

