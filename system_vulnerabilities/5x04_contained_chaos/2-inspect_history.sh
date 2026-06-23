#!/bin/bash
echo "Image: devstream-vulnerable:latest"
echo "Layer History:"

docker_history=$(docker history --format "{{.CreatedBy}}" devstream-vulnerable:latest)
layer=1

while read -r line; do
    echo "  Layer $layer: $line"
    layer=$(( layer + 1))
done < <(echo "$docker_history")

echo "Extracting secrets from history..."
echo -n "  Root password: "
echo "$docker_history" | grep -o "'root:.*'" | tr -d "'" | awk -F':' '{print $2}'
echo -n "  DB password: "
echo "$docker_history" | grep -o "DB_PASSWORD=.*" | awk -F'=' '{print $2}'

echo "CRITICAL: All ENV and RUN commands are permanently visible in image layers."
echo "Never put secrets here!"

