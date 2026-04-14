#!/bin/bash
for octet in $(echo "$1" | tr '.' ' '); do printf " %08d" "$(echo "obase=2; $octet" | bc)"; done | sed 's/ //' | tr ' ' '.' 
