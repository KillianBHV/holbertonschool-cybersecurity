#!/bin/bash
awk -F: '$7~/(sh|bash)$/ && $1 != "root" && $3 < 1000 {print $1}' $1
