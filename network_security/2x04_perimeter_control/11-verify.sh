#!/bin/bash
wg show wg0 | awk -F 'latest handshake:' '/latest handshake/{print $2}'
