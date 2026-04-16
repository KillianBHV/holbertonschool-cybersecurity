#!/bin/bash
grep "option routers" /var/lib/dhcp/dhclient*.leases | tail -n 1 | awk '{print $3}' | tr -d ';'
