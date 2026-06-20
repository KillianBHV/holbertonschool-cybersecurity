#!/bin/bash
echo '=== Password Aging Configuration ==='

echo ''
echo 'Configuring /etc/login.defs...'

if grep -qE '.*PASS_MAX_DAYS.*' /etc/login.defs; then
	sed -i 's/.*PASS_MAX_DAYS.*/PASS_MAX_DAYS  90/' /etc/login.defs
else
	echo 'PASS_MAX_DAYS  90' >> /etc/login.defs
fi

if grep -qE '.*PASS_MIN_DAYS.*' /etc/login.defs; then
	sed -i 's/.*PASS_MIN_DAYS.*/PASS_MIN_DAYS  1/' /etc/login.defs
else
	echo 'PASS_MIN_DAYS  1' >> /etc/login.defs
fi

if grep -qE '.*PASS_WARN_AGE.*' /etc/login.defs; then
	sed -i 's/.*PASS_WARN_AGE.*/PASS_WARN_AGE  14/' /etc/login.defs
else
	echo 'PASS_WARN_AGE  14' >> /etc/login.defs
fi

echo '  PASS_MAX_DAYS: 99999 -> 90'
echo '  PASS_MIN_DAYS: 0 -> 1'
echo '  PASS_MAX_DAYS: 7 -> 14'

echo ''
echo 'Note: These settings apply to NEW accounts only.'
echo 'Existing accounts must be updated with chage.'

echo ''
echo 'Applying to existing users...'

for user in "$(getent passwd | awk -F':' '$3 > 1000 {print $1}' | grep -E "(auditor|developer)")"; do
	chage -m 1 $user
	chage -M 90 $user
	chage -W 14 $user
	echo "  $user: Max=90, Min=1, Warn=14"	
done

echo '  [Skipping system accounts]'

echo ''
echo 'Password aging: CONFIGURED'

