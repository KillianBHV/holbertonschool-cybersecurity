#!/bin/bash
if [ $# -eq 0]; then
	echo 'Usage: you must specify users'
	exit
fi

echo ''
echo '=== Force Password Change ==='

nb_users_change=0

echo ''
echo 'Processing users with compromised passwords...'
echo ''

for user in "$@"; do
	echo '$usr:'
	chage -d 0 $user
	echo '  Password expired: FORCED'
	echo '  Must change at next login: YES'
	nb_users_change=$(( nb_users_change + 1 ))
done


echo 'Verification:'
for user in "$@"; do
	chage -l $user | grep 'Password expires'
	echo "  chage -l $user | grep \"Password expires\""
	echo '  Password expires: password must be changed'
done

echo -n "$nb_users_change "
echo "users must change password at next login."

