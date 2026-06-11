#!/usr/bin/env bash

if [[ ${EUID} -ne 0 ]]; then
  echo "Non-root mode: cannot flush host firewall"
  echo "Run with root:"
  echo "  sudo nft flush ruleset"
  echo "  sudo iptables -F && sudo iptables -t nat -F"
  exit 0
else
  nft flush ruleset

echo "[!] PANIC BUTTON: flushing firewall rules"
fi
