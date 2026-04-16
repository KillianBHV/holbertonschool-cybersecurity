#!/bin/bash
dig "$1" TXT +noall +answer +short +nocomments
