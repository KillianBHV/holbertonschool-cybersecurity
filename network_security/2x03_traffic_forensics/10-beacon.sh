#!/bin/bash
tshark -r "$1" -T fields -e frame.time_epoch -e ip.src -e ip.dst | sort -u

