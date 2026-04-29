#!/bin/bash
tshark -r ~/Downloads/incident.pcap -T fields -e frame.time_epoch -e ip.src -e ip.dst | sort -u
