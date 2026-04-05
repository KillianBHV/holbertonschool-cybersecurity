#!/bin/bash
if [ -d $1 ]
then
    mkdir -p $1/backups/
    for file in $1/*.log; do
	if [ "$(wc -c $file | cut -d' ' -f1)" -gt 1024 ]
	then
	    gzip $file
	    mv $file.gz $1/backups
	else
	    echo "Skipping small file: ${file##*/}"
	fi
    done
else
    exit 1
fi
