#!/bin/bash
dig "$1" MX +noall +answer +short +nocomments | sort -n
