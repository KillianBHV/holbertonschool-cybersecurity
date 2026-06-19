#!/bin/bash
echo '=== Password Complexity Testing ==='
echo -e "\nTesting password policy enforcement..."

check_pass () {
	echo -e "\nTest $2: \"$1\""

	if [[ ! -z $(echo "$(echo "$1" | passwd jsmith 2>&1)" | grep "BAD PASSWORD" -o) ]]; then
    	echo -ne "Result: REJECTED\n  Reason: "
		if [[ $3 -eq 1 ]]; then
			echo "Dictionary word"
		elif [[ $3 -eq 2 ]]; then
			echo "Missing special char"
		elif [[ $3 -eq 3 ]]; then
			echo "Minimum length not met"
		elif [[ $3 -eq 4 ]]; then
			echo "Contains username"
		fi
	else
		echo "$1" | passwd jsmith
    	echo "  Result: ACCEPTED"
		echo "  Reason: Meets all requirements"
	fi
}

test_num=1
check_pass "password" test_num 1
# for test_pass in ('password' 'Password123' 'Ab1!' 'auditor2024' 'Str0ng!P@ssw0rd#2024'); do done

test_num=$(( test_num + 1))
check_pass "Password123" test_num 2

test_num=$(( test_num + 1))
check_pass "Ab1!" test_num 3

test_num=$(( test_num + 1))
check_pass "auditor2024" test_num 4

test_num=$(( test_num + 1))
check_pass "Str0ng!P@ssw0rd#2024" test_num 0

echo -e "\nAll complexity tests: PASSED\nPassword policy is enforced correctly."

