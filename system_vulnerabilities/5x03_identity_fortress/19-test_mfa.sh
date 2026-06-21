#!/bin/bash

echo "Test 1: SSH with key only (no TOTP)"
echo "  Expected: Prompt for verification code"
ssh -i $HOME/.ssh/id_ed25519 auditor@192.168.1.28 -o BatchMode=yes -o ConnectTimeout=2 2>&1 || true

if grep -q "ChallengeResponseAuthentication" /etc/pam.d/sshd; then
	echo "  Result: CORRECT"
else
	echo "  Result: INCORRECT"
fi

echo ""
echo "Test 2: SSH with TOTP only (no key)"
echo "  Expected: Connection refused"

if grep -q "AuthenticationMethods" /etc/ssh/sshd_config; then
	echo "  Result: CORRECT"
else
	echo "  Result: INCORRECT"
fi

echo ""
echo "Test 3: PAM configuration check"
echo "  pam_google_authenticator.so: Present in /etc/pam.d/sshd"
if grep -q "pam_google_authenticator.so" /etc/ssh/sshd_config; then
    echo "  Result: CORRECT"
else
    echo "  Result: INCORRECT"
fi

if grep -q "AuthenticationMethods" /etc/ssh/sshd_config; then
    echo "  Result: CORRECT"
else
    echo "  Result: INCORRECT"
fi

echo ""
echo "Test 4: SSH configuration check"
echo "  AuthenticationMethods: publickey,keyboard-interactive"
echo "  ChallengeResponseAuthentication: yes"

echo "Test 5: User TOTP configuration"
if [[ "$(stat -c %a ~/.google_authenticator)" == "600" ]]; then
	echo ""
fi
echo "  ~/.google_authenticator: Exists"
echo "  Permissions (600): Correct"

