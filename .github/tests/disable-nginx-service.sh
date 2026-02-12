#!/bin/sh

# shellcheck source=/dev/null
. "$(dirname "$0")/include/functions.sh"

check_stack_start

print_heading "check for absence of nginx container"
docker compose ps | grep zammad-nginx && exit 1
print_heading "Success - nginx container is absent"
