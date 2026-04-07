#!/bin/bash
awk -F: '($1 != "root" && $3 == 0) {print $1}' $1
