#!/bin/bash

echo -e "===living off the Land Binaries Audit===\nChecking GTFOBins candidates..."

file_readers=("cat" "tail" "more" "grep" "nano" "vim")
echo -e "\nFile Readers (can read sensitive files):"
for f in ${file_readers[@]}; do
	echo "  /usr/bin/$f: $(stat -c '%A' "/usr/bin/$f") (OK)"
done

shell_escapes=("python3" "awk" "perl")
echo -e "\nShell Escapes:"
for s in ${shell_escapes[@]}; do
	echo "  /usr/bin/$s: $(stat -c '%A' "/usr/bin/$s") (OK)"
done

net_tools=("curl" "wget" "nmap")
echo -e "\nNetwork Tools:"
for n in ${net_tools[@]}; do
	echo "  /usr/bin/$n: $(stat -c '%A' "/usr/bin/$n") (WARNING: Can download payloads)"
done

echo -e "\nNote: These binaries are legitimate but should be monitored.\nSee https://gftobins.github.io/ for abuse techniques"
