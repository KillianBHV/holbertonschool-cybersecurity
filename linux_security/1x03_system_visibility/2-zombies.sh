#!/bin/bash
ps -eo pid,s | awk -F' ' '$2 == "Z" {print $1}'
