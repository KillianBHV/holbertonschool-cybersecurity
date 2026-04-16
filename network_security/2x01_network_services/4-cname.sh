#!/bin/bash
dig "$1" CNAME +noall +answer +short +nocomments
