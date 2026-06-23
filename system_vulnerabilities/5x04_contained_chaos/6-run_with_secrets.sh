#!/bin/bash
# Don't put your secrets on Dockerfiles
# They are visible via layers
# Instead, create environment variables and call them
# directly with docker run command (-e)
#
# In practice, the problem is the same if you hardcode secrets
# in cleartext in scripts. Please consider to encrypt/hashed
# secrets before insert them inside scripts

export DB_USER=${DB_USER:-"root"}
export DB_PASSWORD=${DB_PASSWORD:-"Sup3rS3cr3t!Pr0d"}
export DB_HOST=${DB_HOST:-"prod-db.devstream.internal"}

docker run -e DB_HOST=$DB_HOST -e DB_USER=$DB_HOST -e DB_PASSWORD=$DB_PASSWORD devstream-nosecrets:v1
