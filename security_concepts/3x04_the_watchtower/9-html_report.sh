#!/bin/bash
rows=$(
awk '
/Failed Password/ {
	match($0, /from ([0-9.]+)/, a)
    ip = a[1]
    attacks[ip]++
}
END {
    for (ip in attacks)
        print attacks[ip], ip
}
' "$1" | sort -rn | head -5 | while read count ip
do
    echo "<tr><td>$ip</td><td>$count</td></tr>"
done
)

cat > "$2" <<EOF
<!DOCTYPE html>
<html>
<head><title>Security Report</title></head>
<body>
<h1>Security Report</h1>
<table border="1">
    <tr>
        <th>IP Address</th>
        <th>Attempts</th>
    </tr>
    $rows
</table>
</body>
</html>
EOF
