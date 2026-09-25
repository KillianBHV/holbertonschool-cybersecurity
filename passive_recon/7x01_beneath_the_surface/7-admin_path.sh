#!/bin/bash
curl https://portal.astralis-cloud.example/robots.txt 2>/dev/null | awk '/^Disallow/ {print $2}' | grep -E "(admin|manage|backend|console)" | head -1
