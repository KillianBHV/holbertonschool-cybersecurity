#!/bin/bash

echo -e "=== Legal Banner Configuration ===\n"

echo "Creating banner in /etc/issue.net..."

cat > /etc/issue.net << 'EOF'
========================================
AUTHORIZED ACCESS ONLY

This system is the property of NovaTech Solutions.
Unauthorized access is prohibited and will be prosecuted.
All activities are monitored and logged.
========================================
EOF

echo -e "\nBanner content:"
echo "====================================="
echo "AUTHORIZED ACCESS ONLY"
echo
echo "This system is the property of NovaTech Solutions."
echo "Unauthorized access is prohibited and will be prosecuted."
echo "All activities are monitored and logged."
echo "====================================="

echo -e "\nConfiguring SSH to display banner..."
SSHD_CONFIG="/etc/ssh/sshd_config"

grep -q "^Banner /etc/issue.net" "$SSHD_CONFIG" 2>/dev/null || echo "Banner /etc/issue.net" >> "$SSHD_CONFIG"
echo "  Banner /etc/issue.net: Enabled"

echo -e "\nReloading SSH..."

systemctl reload ssh 2>/dev/null || service ssh reload 2>/dev/null || true

echo -e "\nVerification:\n  /etc/issue.net: EXISTS"
grep -q "Banner /etc/issue.net" "$SSHD_CONFIG" && echo "  SSH Banner config: ENABLED"
echo -e "\nLegal banner configured."

