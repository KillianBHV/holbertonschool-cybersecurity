#!/bin/bash
identity_hardening () {
    sed -i "s/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/" "/etc/login.defs"
    sed -i "s/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   1/" "/etc/login.defs"
    grep -q "^PASS_MIN_LEN" /etc/login.defs || echo "PASS_MIN_LEN   12" >> "/etc/login.defs"
    
    echo "deny = 5" > /etc/security/faillock.conf
    echo "fail_interval = 900" >> /etc/security/faillock.conf
    echo "unlock_time = 600" >> /etc/security/faillock.conf
    
    usermod -L root
    
    # Safe user cleanup
    mapfile -t users_to_remove < <(getent passwd | awk -F: '($3>1000 && $1!="nobody") {print $1}')
    removed_count=0
    for user in "${users_to_remove[@]}"; do
        if id "$user" 2>/dev/null | grep -qE "(sudo|wheel)"; then continue fi
        if userdel -r "$user" 2>/dev/null || userdel "$user" 2>/dev/null; then ((removed_count++)) fi
    done
    echo "$removed_count" > /tmp/users_removed
    
    grep -q 'pam_pwquality.so' /etc/pam.d/common-password || 
    echo "password requisite pam_pwquality.so retry=3 minlen=12 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1" >> /etc/pam.d/common-password
    
    log "Identity Hardening: I-01 I-02 I-03 I-04 complete"
}
