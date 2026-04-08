#!/bin/bash
ps -eo pid,state | awk -F' ' '$2 == "Z" {print $1}'
