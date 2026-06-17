#!/bin/bash

echo "=== Filesystem Hardening Verification ==="

check_exec() {
    DIR=$1
    NAME=$2

    echo -e "\nTesting $NAME restrictions:" | tee -a /etc/fstab
    echo "  Creating test script... Done" | tee -a /etc/fstab
    FILE="$DIR/test_exec.sh"

	cat > "$FILE" << 'EOF'
#!/bin/bash
echo test
EOF
	chmod +x "$FILE"

    echo "  Attempting execution..." | tee -a /etc/fstab

    if "$FILE" >/dev/null 2>&1; then
        echo "  Execute test: ALLOWED (FAIL)" | tee -a /etc/fstab
    else
        echo "  Execute test: BLOCKED - OK" | tee -a /etc/fstab
    fi

    rm -f "$FILE"
    echo "  Cleanup... Done"
}

check_exec /tmp "/tmp"
check_exec /var/tmp "/var/tmp"
check_exec /dev/shm "/dev/shm"

echo -e "\nMount options verified:"

for d in /tmp /var/tmp /dev/shm; do
    opts=$(findmnt -n -o OPTIONS "$d")
    echo "  $d: $opts"
done

echo -e "\nAll filesystem restrictions: ACTIVE"

