#!/bin/bash
echo "Creating application files..."
cat > app.py <<EOF
from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return f"Hello from DevStream! DB: {os.environ.get('DB_HOST', 'unknown')}"

@app.route('/health')
def health():
    return "OK", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

EOF
chmod 755 app.py
echo "  app.py: Created"

echo "flask==3.0.0" > requirements.txt
echo "  requirements.txt: Created"

cat > Dockerfile <<EOF
# DevStream's "production" Dockerfile
# DO NOT USE IN PRODUCTION (but they did)

FROM ubuntu:latest

# Install everything we might need
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3.14-venv \
    curl \
    wget \
    vim \
    net-tools \
    iputils-ping \
    gcc \
    make \
    sudo

# Set root password (for debugging)
RUN echo 'root:devstream123' | chpasswd

# Database credentials
ENV DB_HOST=prod-db.devstream.internal
ENV DB_USER=admin
ENV DB_PASSWORD=Sup3rS3cr3t!Pr0d

# Copy application
WORKDIR /app
COPY . /app

# Install Python dependencies
RUN python3 -m venv venv
RUN venv/bin/python3 -m pip install -r requirements.txt

# Run as root because it's easier
EXPOSE 5000

CMD ["python3", "app.py"]

EOF
echo "  Dockerfile: Created"

echo "Building image..."
echo "  Image: devstream-vulnerable:latest"
if [[ ! -z "$(docker build --check . 2>&1 | grep -o "Check complete")" ]]; then
    echo "  Build: SUCCESS"
else
    echo "  Build: FAILURE"
fi

echo "Image Anlaysis:"
echo "  Size: $(docker images | grep "devstream-vulnerable:latest" | awk -F' ' '{print $4}')"
echo "  Base: $(cat Dockerfile | grep "FROM" | awk -F' ' '{print $2}')"
echo "  User: root (UID 0)"

echo "Environment Variables (EXPOSED SECRETS):"
cat Dockerfile | grep "ENV DB" | sed 's/ENV DB/  DB/g'
echo "WARNING! This image contains hardcoded credentials!"

