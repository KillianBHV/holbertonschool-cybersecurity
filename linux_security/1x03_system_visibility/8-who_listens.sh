#!/bin/bash
lsof -iTCP:$1 2>/dev/null | awk 'NR>1{print $1; exit}'
