#!/bin/bash
squid -k parse && systemctl reload squid || exit 1
