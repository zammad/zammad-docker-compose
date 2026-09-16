#!/bin/sh

set -o errexit

# Load only English and German language models in order to speed up the stack startup.
export LT_LOAD_ONLY="en,de"

# Wait for libretranslate to be ready, as downloading the initialization may take some time.
docker compose -f docker-compose.yml -f scenarios/add-libretranslate.yml up --detach --wait --wait-timeout 300 libretranslate

docker compose -f docker-compose.yml -f scenarios/add-libretranslate.yml up --detach
