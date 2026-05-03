#!/bin/bash
nft add rule inet filter forward ip saddr 10.200.0.0/24 ip daddr != 10.200.0.1 tcp dport 80 drop
nft add rule inet filter forward ip saddr 10.200.0.0/24 ip daddr != 10.200.0.1 tcp dport 443 drop
nft add rule inet filter output ip saddr 10.200.0.1 tcp dport { 80, 443 } accept
