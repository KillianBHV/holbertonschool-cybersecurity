#!/bin/bash
curl -I https://portal.astralis-cloud.example 2>/dev/null | awk '/Server/ {print $2}'
