#!/bin/bash
dec=$(printf "%d" "$(echo "ibase=2; $(for i in $(seq 1 "$1"); do echo -n "1"; done; for i in $(seq 1 "$((32 - $1))"); do echo -n "0"; done)" | bc)"); echo "$(( dec >> 24 )).$(( dec >> 16 & 0xFF)).$(( dec >> 8 & 0xFF )).$(( dec & 0xFF))"
