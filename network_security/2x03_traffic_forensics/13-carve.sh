#!/bin/bash
tshark -r "$1" --export-objects http,/tmp/out >/dev/null 2>&1; md5sum /tmp/out* | sort | head -n1 | awk '{print $1}'

