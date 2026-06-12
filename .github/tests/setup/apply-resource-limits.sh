#!/bin/sh

set -o errexit

docker compose -f docker-compose.yml -f scenarios/apply-resource-limits.yml up --quiet-pull --detach
