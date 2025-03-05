#!/bin/sh

set -o errexit

# Use a custom port to verify it is configurable.
echo "ELASTICSEARCH_EXPOSE_HTTP_PORT=9201" > .env

docker compose -f docker-compose.yml -f scenarios/add-hostport-to-elasticsearch.yml up --quiet-pull --detach
