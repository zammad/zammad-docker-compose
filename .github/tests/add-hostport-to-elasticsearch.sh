#!/bin/sh

# shellcheck source=/dev/null
. "$(dirname "$0")/include/functions.sh"

check_stack_start

print_heading "check for hostport"
docker inspect zammad-docker-compose-zammad-elasticsearch-1 | grep HostPort | grep 9201
print_heading "Success - hostport is present"