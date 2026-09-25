#!/bin/bash
dig astralis-cloud.example SOA +short | awk -F' ' '{sub(/\.$/, "", $1); print $1}'
