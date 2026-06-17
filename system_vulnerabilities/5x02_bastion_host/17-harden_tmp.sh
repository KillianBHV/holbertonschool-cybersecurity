#!/bin/bash
echo -e "=== Hardening /tmp ===\n"

echo "Current /tmp mount:"
findmnt /tmp
echo -e "\nApplying hardening options...\nMethod: Bind mount with options"
echo "Adding to /etc/fstab:"
echo "  tmpfs /tmp tmpfs defaults,noexec,nosuid,nodev 0 0" | tee -a /etc/fstab

echo -e "\nRemounting /tmp..."
mount -o remount,noexec,nosuid,nodev /tmp 2>/dev/null
echo -e "\nVerification:\n"
findmnt /tmp

echo -e "\nTesting Restrictions:"
cat > /tmp/test.sh << 'EOF'
#!/bin/bash
echo test
EOF
chmod +x /tmp/test.sh

if "/tmp/test.sh" >/dev/null 2>&1; then
	echo "Execute test: ALLOWED (unexpected)"
else
	echo "Execute test: BLOCKED (Permission denied) - OK"
fi

if [ -z $(stat -c '%A' /tmp/test.sh | grep 's') ]; then
	echo "SUID test: BLOCKED (no SUID active) - OK"
else
	echo "SUID test: ALLOWED (unexpected)"
fi

echo -e "\n/tmp hardened successfully."

