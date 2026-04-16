#!/bin/bash
dig "$1" SOA +noall +answer +short +nocomments | awk -F' ' '{print $1}'
