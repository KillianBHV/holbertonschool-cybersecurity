#!/bin/bash
tshark -r $1 -T fields -e tcp.dstport -Y 'frame contains "uid=0" or frame contains "root"' | sort -u
