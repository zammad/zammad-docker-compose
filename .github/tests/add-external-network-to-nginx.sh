#!/bin/sh

# shellcheck source=/dev/null
. "$(dirname "$0")/include/functions.sh"

check_stack_start

print_heading "check for presence of external network"
docker inspect zammad-docker-compose-zammad-nginx-1 | grep zammad-ci-external-network
print_heading "Success - external network is present"

print_heading "check that nginx is not exposed on the Host"
docker inspect zammad-docker-compose-zammad-nginx-1 | grep HostPort && exit 1
print_heading "Success - nginx is not exposed on the host"
