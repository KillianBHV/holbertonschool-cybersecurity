#!/bin/bash

# Identity Hardening

source config/harden.cfg
source logging.sh

PAM_CONFIG_FILE="/etc/pam.d/common-password"
COMMON_PAM_FILE="/etc/pam/common-auth"
LOGGING_DEFS_FILE="/etc/login.defs"

# Backup data safety
cp "$PAM_CONFIG_FILE" "$PAM_CONFIG_FILE.backup"
cp "$LOGGING_DEFS_FILE" "$LOGGING_DEFS_FILE.backup"
cp "$COMMON_PAM_FILE" "$COMMON_PAM_FILE.backup"

# I-01) Specific password policy set
echo "password requisite		pam_pwquality.so minlen=$PASS_MIN_LENGTH ucredit=-1 lcredit=-1 dcredit=1 ocredit=-1" > $PAM_CONFIG_FILE 
echo "password sufficient		pam_unix.so sha512 shadow use_authtok" >> $PAM_CONFIG_FILE
echo "PASS_MAX_DAYS $PASS_MAX_DAYS" > $LOGGING_DEFS_FILE 

# I-02) Login attempts protection
echo "auth required		pam_faillock.so preauth deny=$FAIL_LOCK_ATTEMPTS unlock_time=$UNLOCK_TIME" > $COMMON_PAM_FILE 
echo "auth [default=die] 	pam_faillock.so authfail deny=$FAIL_LOCK_ATTEMPTS unlock_time=$UNLOCK_TIME" >> $COMMON_PAM_FILE
echo "account required 	pam_faillock.so" >> $COMMON_PAM_FILE

log "SUCCESS" "Password policies and tries set."

# I-03) Delete unnecessary users
users_to_delete=0
audit "INFO" "x unauthorized users removed:"

# Don't forget to search secondary groups, not only first
# awk -F':' '($3>=1000) {print $1}' passwd | 
while read -r user; do
	is_any_group_present=0

	for group in $ONLY_GROUPS_ALLOWED; do
		echo $(id -nG $user) | grep -q "$group"
		
		if [ $? -ne 0 ]; then
			is_any_group_present=$(( is_any_group_present + 1 ))
		else
			is_any_group_present=0
			break
		fi
	done

	if [ $is_any_group_present -ne 0 ]; then
		deluser $user 2>/dev/null
		users_to_delete=$(( users_to_delete + 1 ))
		audit "" "$user"
	fi
done < <(awk -F':' '($3 > 1000) {print $1}' /etc/passwd)

# Audit Report: Reformat
sed -i 's/\[\]/,/g' audit_report.txt
sed -i ':a;N;$!ba;s/\n,/,/g' audit_report.txt
sed -i 's/:,/:/g' audit_report.txt
sed -i "s/x unauthorized/$users_to_delete unathorized/g" audit_report.txt

# I-04) Lock root-password
usermod -L root

log "SUCCESS" "Lock access and remove user accounts OK."
rm -rf "$PAM_CONFIG_FILE.backup"
rm -rf "$LOGGING_DEFS_FILE.backup"
rm -rf "$COMMON_PAM_FILE.backup"
