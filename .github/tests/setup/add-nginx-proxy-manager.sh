#!/bin/sh

set -o errexit

docker compose -f docker-compose.yml -f scenarios/add-nginx-proxy-manager.yml up --pull always --quiet-pull --detach