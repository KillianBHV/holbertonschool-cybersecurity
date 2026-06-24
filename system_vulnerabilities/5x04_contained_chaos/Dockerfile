# DevStream's "production" Dockerfile
# DO NOT USE IN PRODUCTION (but they did...)

# Don't put your secrets on Dockerfiles: they are visible via layers
# Instead, create environment variables and call them
# directly with docker run command (-e)
#
# In practice, the problem is the same if you hardcode secrets
# in cleartext in scripts. Please consider to encrypt/hashed
# secrets before insert them inside scripts

FROM python:3.11 AS builder

RUN apt-get update && apt-get install -y gcc make

WORKDIR /app
COPY . /app

RUN python3 -m venv venv
RUN venv/bin/pip install -r requirements.txt
# RUN venv/bin/pip cache purge


FROM python:3.11-slim

WORKDIR /app
COPY --from=builder /app/requirements.txt requirements.txt

RUN python3 -m venv venv
RUN venv/bin/pip install -r requirements.txt
RUN venv/bin/pip cache purge

COPY --from=builder /app/app.py app.py

CMD ["/venv/bin/python3", "app.py"]
