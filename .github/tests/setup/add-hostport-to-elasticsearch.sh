#!/bin/sh

set -o errexit

docker compose -f docker-compose.yml -f scenarios/add-hostport-to-elasticsearch.yml up --detach
