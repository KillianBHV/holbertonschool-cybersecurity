#!/bin/bash
if [ -z $(wafw00f -a https://portal.astralis-cloud.example 2>/dev/null | grep "WAF detected" | grep -Eo "[0-9]+") ]; then curl -I https://portal.astralis-cloud.example 2>/dev/null | awk '/CF-RAY:/ {print "Cloudfare"}'; fi | head -1
