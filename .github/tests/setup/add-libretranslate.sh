#!/bin/sh

set -o errexit

docker compose -f docker-compose.yml -f scenarios/add-libretranslate.yml up --detach
