#!/bin/sh

set -o errexit

docker compose -f docker-compose.yml -f scenarios/disable-backup-service.yml up --quiet-pull --detach