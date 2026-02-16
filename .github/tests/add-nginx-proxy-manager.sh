#!/bin/sh

# shellcheck source=/dev/null
. "$(dirname "$0")/include/functions.sh"

check_stack_start

print_heading "check for presence nginx-proxy-manager container"
docker compose ps | grep nginx-proxy-manager
print_heading "Success - nginx-proxy-manager container is present"


print_heading "check trusted proxy configuration for nginx-proxy-manager"
railsserver_run_command bundle exec rails r "pp Zammad::TrustedProxies.fetch"
railsserver_run_command bundle exec rails r "Zammad::TrustedProxies.fetch.count.one?"
print_heading "Success- check trusted proxy configuration for nginx-proxy-manager"