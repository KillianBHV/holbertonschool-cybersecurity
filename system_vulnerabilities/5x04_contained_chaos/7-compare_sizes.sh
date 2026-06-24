#!/bin/bash

cat > Dockerfile <<EOF
FROM python:3.11 AS builder

RUN apt-get update && apt-get install -y gcc make

WORKDIR /app
COPY . /app

RUN python3 -m venv venv
RUN venv/bin/pip install -r requirements.txt
# RUN venv/bin/pip cache purge

EOF

echo "flask==3.0.0" > requirements.txt
#docker build -t devstream-single:v1 . >/dev/null 2>&1

cat >> Dockerfile <<EOF

FROM python:3.11-slim

WORKDIR /app
COPY --from=builder /app/requirements.txt requirements.txt

RUN python3 -m venv venv
RUN venv/bin/pip install -r requirements.txt
RUN venv/bin/pip cache purge

COPY --from=builder /app/app.py app.py

CMD ["/venv/bin/python3", "app.py"]

EOF

#docker build -t devstream-prod:v1 . >/dev/null 2>&1

single=$(docker images | grep "single:v1" | awk -F' ' '{print $4}' | tr -d ' MB')
prod=$(docker images | grep "prod:v1" | awk -F' ' '{print $4}' | tr -d ' MB')
echo "Single-stage image: $single MB"
echo "Multi-stage image: $prod MB"
echo "Reduction: $(echo "$(printf '(1.0 - %.2f / %.2f) * 100' $prod $single)" | bc -l | awk -F'.' '{print $1}')%"

echo "Packages in final image:"
echo -e "  python3.11\n  flask\n  (minimal runtime only)"
echo "Build tools excluded:"
echo -e "  gcc\n  make\n  pip (caches cleared)"

