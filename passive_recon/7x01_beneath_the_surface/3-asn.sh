#!/bin/bash
curl -s -m 10 "https://api.bgpview.io/ip/$(dig astralis-cloud.example +short | head -1)" | jq -r '.data.prefixes[0].asn.asn' | awk '{print "AS"$1}'
