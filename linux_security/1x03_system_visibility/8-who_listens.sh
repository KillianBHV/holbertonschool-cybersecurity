#!/bin/bash
lsof -n -P -iTCP:$1 -sTCP:LISTEN 2>/dev/null | awk 'NR==2{print $1; exit}'
