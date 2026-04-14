#!/bin/bash
printf "%d\n" "$(echo "obase=10; ibase=2; $1" | bc)"
