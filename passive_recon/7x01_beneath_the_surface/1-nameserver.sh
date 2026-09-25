#!/bin/bash
dig astralis-cloud.example NS +short | awk -F' ' '{sub(/\.$/, ""); print}'
