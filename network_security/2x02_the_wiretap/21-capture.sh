#!/bin/bash
sudo tcpdump -c 50 -i tun0 -w cap.pcap
