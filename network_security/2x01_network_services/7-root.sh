#!/bin/bash
dig "$1" +noall +answer +trace +short +nocomments | grep "^A" | awk -F' ' 'NR==1 {print $2}'
