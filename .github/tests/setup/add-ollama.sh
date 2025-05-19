#!/bin/sh

set -o errexit

docker compose -f docker-compose.yml -f scenarios/add-ollama.yml up --pull always --quiet-pull --detach