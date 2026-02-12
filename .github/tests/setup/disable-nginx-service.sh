#!/bin/sh

set -o errexit

# Disable ES initialization in the test because we don't have an external ES service.
echo "NGINX_ENABLED=false" > .env

docker compose -f docker-compose.yml -f scenarios/disable-nginx-service.yml up --pull always --quiet-pull --detach
