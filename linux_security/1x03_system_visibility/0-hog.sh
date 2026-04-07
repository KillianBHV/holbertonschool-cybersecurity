#!/bin/bash
ps -eo pid,euser --no-headers --sort=pcpu | awk -F' ' 'NR==1 {print $1 " " $2}'
