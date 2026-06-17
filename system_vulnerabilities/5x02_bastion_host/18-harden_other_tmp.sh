#!/bin/bash

echo "=== Hardening /var/tmp and /dev/shm ==="

echo
echo "Hardening /var/tmp..."

mount --bind /tmp /var/tmp 2>/dev/null
mount -o remount,bind,noexec,nosuid,nodev /var/tmp 2>/dev/null

echo "  /var/tmp hardened"
echo -e "\nHardening /dev/shm..."

mount -o remount,noexec,nosuid,nodev /dev/shm 2>/dev/null

echo "  /dev/shm hardened"
echo -e "\nVerification:"

echo -n "  /var/tmp: "
findmnt -n -o OPTIONS /var/tmp

echo -n "  /dev/shm: "
findmnt -n -o OPTIONS /dev/shm

echo -e "\nAll temporary directories hardened."

