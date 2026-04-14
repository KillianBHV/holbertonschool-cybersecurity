#!/bin/bash
val=$1; for i in {7..0..-1}; do if [[ $((val-2**i)) -ge 0 ]]; then echo -n "1"; ((val-=2**i)); else echo -n "0"; fi done
