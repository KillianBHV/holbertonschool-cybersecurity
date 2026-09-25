#!/bin/bash
curl -sI https://portal.astralis-cloud.example 2>/dev/null | awk '/^Server:/ { sub(/\r$/, ""); print $2}' | head -1
