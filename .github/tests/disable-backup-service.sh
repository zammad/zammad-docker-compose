#!/bin/sh

# shellcheck source=/dev/null
. "$(dirname "$0")/include/functions.sh"

check_stack_start

print_heading "check for absence of backup container"
docker compose ps | grep zammad-backup && exit 1
print_heading "Success - backup container is absent"
