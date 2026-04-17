traceroute google.com | tail -n 1 | awk -F' ' '{print $1}'
