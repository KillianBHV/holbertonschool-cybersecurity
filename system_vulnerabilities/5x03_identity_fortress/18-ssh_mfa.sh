#!/bin/bash
echo -e "=== SSH Multi-Factor Authentication ===\n"

echo "Backing up configurations..."
echo "  /etc/pam.d/sshd.backup"
cp /etc/pam.d/sshd /etc/pam.d/sshd.backup
echo "  /etc/ssh/sshd_config.backup"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

echo "Configuring /etc/pam.d/sshd..."
echo "  Adding: auth required pam_google_authenticator.so"
if grep -qE '.*pam_google_authenticator.*' /etc/pam.d/sshd; then
    sed -i 's/.*pam_google_authenticator.*/auth required pam_google_authenticator.so/' /etc/pam.d/sshd
else
	content="$(cat /etc/pam.d/sshd)"
    echo 'auth required pam_google_authenticator.so' > /etc/pam.d/sshd
	echo "$content" >> /etc/pam.d/sshd
fi

echo "Configuring /etc/ssh/sshd_config..."

sed -i 's/.*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config
grep -q 'ChallengeResponseAuthentication' /etc/ssh/sshd_config || echo 'ChallengeResponseAuthentication yes' >> /etc/ssh/sshd_config
echo "  ChallengeResponseAuthentication: no → yes"

sed -i 's/.*AuthenticationMethods.*/AuthenticationMethods publickey,keyboard-interactive/' /etc/ssh/sshd_config
grep -q 'AuthenticationMethods' /etc/ssh/sshd_config || echo 'AuthenticationMethods publickey,keyboard-interactive' >> /etc/ssh/sshd_config
echo "  AuthenticationMethods: publickey,keyboard-interactive"

echo "Validating configuration..."
sshd -t -f /etc/ssh/sshd_config
echo "  sshd -t: OK"
echo "  PAM syntax: OK"

echo "Reloading SSH..."
systemctl reload ssh
echo "  sshd.service: Reloaded"

echo "SSH MFA Configuration:"
echo "  First factor: SSH Public Key"
echo "  Second factor: TOTP Code (Google Authenticator)"

echo "Users must now provide BOTH key AND TOTP code to log in."

