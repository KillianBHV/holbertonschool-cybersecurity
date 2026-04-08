#!/bin/bash
awk -v now="$(date +%s)" '{print}' "$1"
