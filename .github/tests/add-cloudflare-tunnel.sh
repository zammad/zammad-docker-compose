#!/bin/sh

# shellcheck source=/dev/null
. "$(dirname "$0")/include/functions.sh"

check_stack_start

print_heading "check for presence cloudflare tunnel container"
docker compose ps | grep cloudflare-tunnel
print_heading "Success - cloudflare container is present"
