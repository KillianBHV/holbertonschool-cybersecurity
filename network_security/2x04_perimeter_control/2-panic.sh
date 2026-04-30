#!/bin/bash
nft flush ruleset && nft 'add table inet filter' && nft 'add chain inet filter input { type filter hook input priority filter; policy accept; }' && nft 'add chain inet filter output { type filter hook output priority filter; policy accept; }' && nft 'add chain inet filter forward { type filter hook forward priority filter; policy accept; }' && echo "./2-panic.sh" | at now + 5 minutes
