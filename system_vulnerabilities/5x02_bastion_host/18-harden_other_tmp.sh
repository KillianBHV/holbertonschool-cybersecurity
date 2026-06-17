#!/bin/bash

echo "=== Hardening /var/tmp and /dev/shm ===" | tee -a /etc/fstab

echo -e "Hardening /var/tmp..." | tee -a /etc/fstab

mount --bind /tmp /var/tmp 2>/dev/null | tee -a /etc/fstab
mount -o remount,bind,noexec,nosuid,nodev /var/tmp 2>/dev/null | tee -a /etc/fstab

echo "  /var/tmp hardened" | tee -a /etc/fstab
echo -e "\nHardening /dev/shm..." | tee -a /etc/fstab

mount -o remount,noexec,nosuid,nodev /dev/shm 2>/dev/null | tee -a /etc/fstab

echo "  /dev/shm hardened" | tee -a /etc/fstab
echo -e "\nVerification:" | tee -a /etc/fstab

echo -n "  /var/tmp: " | tee -a /etc/fstab
findmnt -n -o OPTIONS /var/tmp | tee -a /etc/fstab

echo -n "  /dev/shm: " | tee -a /etc/fstab
findmnt -n -o OPTIONS /dev/shm | tee -a /etc/fstab

echo -e "\nAll temporary directories hardened." | tee -a /etc/fstab

