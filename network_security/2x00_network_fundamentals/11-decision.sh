#!/bin/bash
ip route get "$1" | head -n 1 | awk '{if($0~/via/) print "REMOTE"; else print "LOCAL"}'
