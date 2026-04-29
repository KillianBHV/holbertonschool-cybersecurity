#!/bin/bash
tshark -r ~/Downloads/incident.pcap -T fields -e ip.src | awk 'NF' | sort | uniq -c | sort -nr | awk '{print $2}'
