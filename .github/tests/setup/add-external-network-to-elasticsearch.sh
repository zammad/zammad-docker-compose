#!/bin/sh

set -o errexit

docker network create zammad-ci-external-network

echo "ZAMMAD_ELASTICSEARCH_EXTERNAL_NETWORK=zammad-ci-external-network" > .env

docker compose -f docker-compose.yml -f scenarios/add-external-network-to-elasticsearch.yml up --quiet-pull --detach
