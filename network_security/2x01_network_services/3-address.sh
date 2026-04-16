#!/bin/bash
dig "$1" A +noall +answer +short +nocomments
