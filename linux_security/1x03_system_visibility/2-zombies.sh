#!/bin/bash
ps -el | awk -F' ' '$2 == "Z" {print $4}'
