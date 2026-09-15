#!/bin/sh

set -o errexit

# Wait for libretranslate to be ready (downloading the models may take several minutes).
docker compose -f docker-compose.yml -f scenarios/add-libretranslate.yml up --detach --wait --wait-timeout 900 libretranslate

docker compose -f docker-compose.yml -f scenarios/add-libretranslate.yml up --detach
