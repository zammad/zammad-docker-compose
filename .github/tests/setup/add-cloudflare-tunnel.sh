#!/bin/sh

set -o errexit

docker network create zammad-ci-external-network

echo "CLOUDFLARE_TUNNEL_TOKEN=invalid-token" > .env

docker compose -f docker-compose.yml -f modules/add-cloudflare-tunnel.yml up --detach