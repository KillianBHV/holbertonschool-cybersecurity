#!/bin/bash
ps -eo pid,pcpu,comm --sort=-pcpu --no-headers | awk 'NR==1 {print $1 " " $3}'
