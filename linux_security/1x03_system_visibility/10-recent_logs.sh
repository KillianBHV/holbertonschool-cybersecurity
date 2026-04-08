#!/bin/bash
while read l; do ts=$(date -d $'\b'"$(echo "$l" | awk '{print $1,$2,$3}')" $'\b' +%s); now=$(date +%s); (( now - ts <= 1800 )) && echo "$l"; done < "$1"
