#!/bin/bash
echo -e "=== Google Authenticator Installation ===\n"

echo "Installing libpam-google-authenticator..."
if [[ -z "$(dpkg -s libpam-google-authenticator 2>/dev/null | grep -oF "ok installed")" ]]; then
    apt install -y libpam-google-authenticator
    echo "  Installation complete"
else
    echo "  Already installed: libpam-google-authenticator"
fi

echo -ne "\nModule location:\n  "
find /lib/x86_64-linux-gnu/security/pam_google_authenticator.so

echo -e "\nNext steps:"
echo "  1. Run 'google-authenticator' as each user to generate secrets"
echo "  2. Configure /etc/pam.d/sshd to require the module"
echo "  3. Enable ChallengeResponseAuthentication in sshd_config"

echo -e "\nGoogle Authenticator PAM module: INSTALLED"

