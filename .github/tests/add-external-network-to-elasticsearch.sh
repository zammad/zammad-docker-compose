#!/bin/sh

# shellcheck source=/dev/null
. "$(dirname "$0")/include/functions.sh"

check_stack_start

print_heading "check for presence of external network"
docker inspect zammad-docker-compose-zammad-elasticsearch-1 | grep zammad-ci-external-network
print_heading "Success - external network is present"