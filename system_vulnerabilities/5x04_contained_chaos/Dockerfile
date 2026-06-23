# DevStream's "production" Dockerfile
# DO NOT USE IN PRODUCTION (but they did...)

# Don't put your secrets on Dockerfiles: they are visible via layers
# Instead, create environment variables and call them
# directly with docker run command (-e)
#
# In practice, the problem is the same if you hardcode secrets
# in cleartext in scripts. Please consider to encrypt/hashed
# secrets before insert them inside scripts

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
