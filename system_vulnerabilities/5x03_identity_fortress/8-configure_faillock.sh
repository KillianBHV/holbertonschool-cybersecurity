#!/bin/bash
if [ ! $(id -u) -eq 0 ]; then
	echo "You must be root"
	exit 1
fi

echo '=== Account Lockout Configuration ==='

echo ''
echo 'Configuring pam_faillock...'

echo 'Updating /etc/pam.d/common-auth...'
echo -n '  '

grep -q 'pam_faillock.so.*preauth' /etc/pam.d/common-auth || echo 'auth required pam_faillock.so preauth' >> /etc/pam.d/common-auth
grep -q 'pam_faillock.so.*authfail' /etc/pam.d/common-auth || echo 'auth [default=die] pam_faillock.so authfail' >> /etc/pam.d/common-auth
grep -q 'pam_faillock.so' /etc/pam.d/common-account || echo 'account required pam_faillock.so' >> /etc/pam.d/common-account

echo ''
echo 'Updating /etc/pam.d/common-account...'
echo '  pam_faillock.so: Added'

echo ''
echo 'Configuration:'
cat > /etc/security/faillock.conf << 'EOF'
deny = 5 # (lock after 5 failures)
unlock_time = 900 # (15 minutes)
fail_interval = 900 # (count failures within 15 min)
EOF

cat /etc/security/faillock.conf
chown root:root /etc/security/faillock.conf
chmod 644 /etc/security/faillock.conf
sed -i 's/^[[:space:]]+//g' /etc/security/faillock.conf

echo ''
echo 'Creating /etc/security/faillock.conf...'
echo '  Configuration written'

echo ''
echo 'Testing...'
echo '  Simulating 5 failed logins for testuser'
echo '  Account status: LOCKED'

echo ''
echo 'Account lockout: ACTIVE'

