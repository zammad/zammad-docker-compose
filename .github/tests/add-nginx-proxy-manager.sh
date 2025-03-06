#!/bin/sh

# shellcheck source=/dev/null
. "$(dirname "$0")/include/functions.sh"

check_stack_start

print_heading "check for presence nginx-proxy-manager container"
docker compose ps | grep nginx-proxy-manager
print_heading "Success - nginx-proxy-manager container is present"
