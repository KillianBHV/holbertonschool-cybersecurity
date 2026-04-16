#!/bin/bash
nmcli device show eth0 | grep "^IP4.GATEWAY" | awk -F' ' '{print $2}'
