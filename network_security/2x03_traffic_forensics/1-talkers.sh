#!/bin/bash
tshark -r "$1" -T fields -e ip.src | awk 'NF' | sort | uniq -c | sort -nr | awk '{print $2}'

