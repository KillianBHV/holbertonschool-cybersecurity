#!/bin/bash
awk -v now="$(echo -n $'\b'"$(date +%s)"$'\b')" '{logtime=mktime(sprintf("%s %s %s %s", "2026", $1, $2, $3));if(now-logtime<=1800) print}' "$1"
