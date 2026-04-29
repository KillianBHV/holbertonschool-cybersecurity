#!/bin/bash
tshark -r $1 -T fields -e frame.time -Y 'ip.addr' | awk 'NR==1; END{print}'
