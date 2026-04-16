#!/bin/bash
dig AXFR $1 @$2 +noall +answer +short +nocomments
