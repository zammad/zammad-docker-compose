#!/bin/sh

set -o errexit

docker compose -f docker-compose.yml -f modules/add-nginx-proxy-manager.yml up --detach