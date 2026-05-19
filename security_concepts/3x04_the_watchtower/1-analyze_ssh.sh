#!/bin/bash
grep "Failed password" "$1" | grep -Eo '^((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)$' | sort | uniq -c | sort -rn

