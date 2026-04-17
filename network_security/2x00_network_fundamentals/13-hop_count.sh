#!/bin/bash
traceroute "$1" | tail -n 1 | awk -F' ' '{print $1}'
