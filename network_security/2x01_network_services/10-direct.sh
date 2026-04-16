#!/bin/bash
dig @$1 $2 +noall +answer +short +nocomments
