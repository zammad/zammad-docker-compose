#!/bin/sh

set -o errexit

docker network create zammad-ci-external-network

echo "EXTERNAL_NETWORK=zammad-ci-external-network" > .env

docker compose -f docker-compose.yml -f modules/add-external-network-to-nginx.yml up --detach
