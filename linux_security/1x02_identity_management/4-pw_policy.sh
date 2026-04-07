#!/bin/bash
dpkg -S "$1" > /dev/null 2>&1
if [ $? -ne 0 ]; then
	apt-get install -y $1 > /dev/null 2>&1
fi

echo 'passwd  password required		pam_pwquality.so minlen=12 minclass=3' > $2
