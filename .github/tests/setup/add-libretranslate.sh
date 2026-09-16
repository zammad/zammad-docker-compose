#!/bin/sh

set -o errexit

# Wait for libretranslate to be ready, as downloading the initialization may take some time.
#   Load only English (en) language in order to speed up the stack startup.
LT_LOAD_ONLY=en docker compose -f docker-compose.yml -f scenarios/add-libretranslate.yml up --detach --wait --wait-timeout 900 libretranslate

LT_LOAD_ONLY=en docker compose -f docker-compose.yml -f scenarios/add-libretranslate.yml up --detach
