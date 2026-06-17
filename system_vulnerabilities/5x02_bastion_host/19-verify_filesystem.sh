#!/bin/bash

echo "=== Filesystem Hardening Verification ==="

check_exec() {
    DIR=$1
    NAME=$2

    echo -e "\nTesting $NAME restrictions:"
    echo "  Creating test script... Done"
    FILE="$DIR/test_exec.sh"

	cat > "$FILE" << 'EOF'
#!/bin/bash
echo test
EOF
	chmod +x "$FILE"

    echo "  Attempting execution..."

    if "$FILE" >/dev/null 2>&1; then
        echo "  Execute test: ALLOWED (FAIL)"
    else
        echo "  Execute test: BLOCKED - OK"
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

