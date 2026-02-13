#!/bin/sh

# shellcheck source=/dev/null
. "$(dirname "$0")/include/functions.sh"

check_stack_start false # do not use nginx

print_heading "check for absence of nginx container"
docker compose ps | grep zammad-nginx
print_heading "Success - nginx container is absent"
