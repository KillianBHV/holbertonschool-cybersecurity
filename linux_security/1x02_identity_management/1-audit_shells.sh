#!/bin/bash
awk -F: '/(sh|bash)$/ && $1 != "root" && $3 < 1000 {print $1}' $1
