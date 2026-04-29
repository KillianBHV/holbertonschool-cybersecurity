#!/bin/bash
tshark -r "$1" -T fields -e urlencoded-form.value | awk -F',' 'NF {print $2}' | grep -E "^(password|pass|pwd)"

