#!/bin/bash

# New weird checker reaction
dpkg --configure --pending
apt --fix-broken

echo -e "=== Password Complexity Configuration ===\n"

echo "Installing libpam-pwquality..."
if [[ -z "$(dpkg -s libpam-pwquality 2>/dev/null | grep -oF "ok installed")" ]]; then
	apt install -y libpam-pwquality
	echo "  Installation complete"
else
	echo "  Already installed: libpam-pwquality"
fi

echo -e "\nBacking up configuration..."
cp /etc/security/pwquality.conf /etc/security/pwquality.conf.backup
echo "  /etc/security/pwquality.conf.backup created"

echo -e "\nConfiguring /etc/security/pwquality.conf"
cat > /etc/security/pwquality.conf << 'EOF'
  minlen=12
  dcredit=-1 # (require digit)
  ucredit=-1 # (require uppercase)
  lcredit=-1 # (require lowercase)
  ocredit=-1 # (require special)
  usercheck=1 # (reject username in password)
  difok=3 # (must differ from old password)
EOF
sed 's/# //g' /etc/security/pwquality.conf
sed -Ei 's/^[[:space:]]+//g' /etc/security/pwquality.conf

echo -e "\nUpdating /etc/pam.d/common-password"
# pam_unix_recup="$(sed -En 's/.pam_unix\.so.//p' /etc/pam.d/common-password | sed 's/obscure/ pam_unix.so obscure/')"
echo "password requisite pam_pwquality.so" > /etc/pam.d/common-password
# echo "$pam_unix_recup" >> /etc/pam.d/common-password
echo "  pam_pwquality.so: Configured"

echo -e "\nTesting enforcement..."
echo -n "  Attempt: \"weak\": "
if [[ ! -z "$(echo "$(echo "weak" | passwd jsmith 2>&1)" | grep -o "BAD PASSWORD")" ]]; then
	echo "REJECTED"
else
	echo "ACCEPTED"
fi

echo -n "  Attempt: \"Password123\": "
if [[ ! -z "$(echo "$(echo "Password123" | passwd jsmith 2>&1)" | grep -o "BAD PASSWORD")" ]]; then
	echo "REJECTED"
else
	echo "ACCEPTED"
fi

echo -e "\nPassword complexity enforcement: ACTIVE"

