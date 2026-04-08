#!/bin/bash
ss -l -t -p -n -4 | awk 'NR!=1{split($4, a, ":"); print a[2]}' | sort | uniq
