#!/bin/sh

# shellcheck source=/dev/null
. "$(dirname "$0")/include/functions.sh"

print_heading "wait for zammad to be ready…"
docker compose wait zammad-init
docker compose exec zammad-nginx bash -c "curl --retry 30 --retry-delay 1 --retry-connrefused http://localhost:8080 | grep 'Zammad'"
print_heading "Success - Zammad is up :)"

print_heading "check for absence of elasticsearch container"
docker compose ps | grep zammad-elasticsearch && exit 1
print_heading "Success - elasticsearch container is absent"
