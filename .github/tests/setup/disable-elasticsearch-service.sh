#!/bin/sh

set -o errexit

# Disable ES initialization in the test because we don't have an external ES service.
echo "ELASTICSEARCH_ENABLED=false" > .env

docker compose -f docker-compose.yml -f scenarios/disable-elasticsearch-service.yml up --quiet-pull --detach