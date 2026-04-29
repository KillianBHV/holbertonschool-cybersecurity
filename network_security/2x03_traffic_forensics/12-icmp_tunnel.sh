#!/bin/bash
tshark -r $1 -T fields -e ip.src -Y 'icmp and frame.len > 100'
