# DevStream's "production" Dockerfile
# DO NOT USE IN PRODUCTION (but they did...)

FROM ubuntu:latest

# Install everything we might need
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    wget \
    vim \
    net-tools \
    iputils-ping \
    gcc \
    make \
    sudo

# Copy application
WORKDIR /app
COPY . /app

# Install Python dependencies
RUN pip3 install -r requirements.txt

# Run as root because it's easier
EXPOSE 5000

CMD ["python3", "app.py"]
