#!/bin/sh

set -o errexit

# Load only English (en) language in order to speed up the stack startup.
LT_LOAD_ONLY=en docker compose -f docker-compose.yml -f scenarios/add-libretranslate.yml up --detach
