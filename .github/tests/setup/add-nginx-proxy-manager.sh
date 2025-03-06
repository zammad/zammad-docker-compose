#!/bin/sh

set -o errexit

docker compose -f docker-compose.yml -f scenarios/add-nginx-proxy-manager.yml up --quiet-pull --detach