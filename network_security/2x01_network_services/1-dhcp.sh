#!/bin/bash
grep "dhcp-server-identifier" /var/lib/dhcp/dhclient*.leases 2>/dev/null | tail -n 1 | awk '{print $3}' | tr -d ';'
