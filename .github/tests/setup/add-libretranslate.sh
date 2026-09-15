#!/bin/sh

set -o errexit

docker compose -f docker-compose.yml -f scenarios/add-libretranslate.yml up --detach

# Wait for libretranslate to be ready (downloading the models may take several minutes).
docker compose -f docker-compose.yml -f scenarios/add-libretranslate.yml up --detach --wait --wait-timeout 900 libretranslate
