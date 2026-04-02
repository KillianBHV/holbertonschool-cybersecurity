#!/bin/bash
find "$1" -size +1M -type f ! -regex "*.gz" 2>/dev/null
