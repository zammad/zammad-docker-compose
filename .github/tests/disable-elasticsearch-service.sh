#!/bin/sh

# shellcheck source=/dev/null
. "$(dirname "$0")/include/functions.sh"

check_stack_start

print_heading "check for absence of elasticsearch container"
docker compose ps | grep zammad-elasticsearch && exit 1
print_heading "Success - elasticsearch container is absent"
