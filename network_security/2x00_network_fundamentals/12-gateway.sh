#!/bin/bash
netstat -nr | grep "^0\.0\.0\.0" | awk -F' ' '{print $2}'
