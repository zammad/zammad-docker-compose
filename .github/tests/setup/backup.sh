#!/bin/sh

set -o errexit

echo "ELASTICSEARCH_ENABLED=false" > .env

docker compose up --detach
