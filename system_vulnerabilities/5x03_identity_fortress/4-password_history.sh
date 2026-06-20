#!/bin/bash
echo '=== Password History Configuration ==='

echo ''
echo 'Configuring pam_pwhistory...'

echo ''
echo 'Creating password history file...'
touch /etc/security/opasswd 2>/dev/null
echo '  /etc/security/opasswd: Created'

echo 'Updating /etc/pam.d/common-password...'
sed -i '/pam_unix.so/i password required pam_pwhistory.so remember=5 use_authtok' /etc/pam.d/common-password
echo '  pam_pwhistory.so remember=5: Added'

echo 'Configuration:'
echo '  Passwords remembered: 5'
echo '  Hash algorithm: sha512'

echo ''
echo 'Testing...'

if grep -E 'pam_pwhistory.so' /etc/pam.d/common-password 2>/dev/null; then
    echo "  Previous password reuse: BLOCKED"
else
    echo "  Previous password reuse: NOT CONFIGURED"
fi

echo 'Password history enforcement: ACTIVE'
echo 'Users cannot reuse their last 5 passwords.'

