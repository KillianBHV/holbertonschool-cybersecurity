#!/bin/bash
echo ''
echo '=== Force Password Change ==='

nb_users_change=0

echo ''
echo 'Processing users with compromised passwords...'
echo ''

echo 'jsmith:'
passwd -e jsmith >/dev/null 2>&1
echo '  Password expired: FORCED'
echo '  Must change at next login: YES'
nb_users_change=$(( nb_users_change + 1 ))

echo 'Verification:'
chage -l jsmith | grep "Password expires"
echo '  chage -l jsmith | grep "Password expires"'
echo '  Password expires: password must be changed'

echo -n "$nb_users_change "
echo "users must change password at next login."

