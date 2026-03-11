#!/bin/sh

# shellcheck source=/dev/null
. "$(dirname "$0")/include/functions.sh"

check_stack_start

print_heading "check for presence nginx-proxy-manager container"
docker compose ps | grep nginx-proxy-manager
print_heading "Success - nginx-proxy-manager container is present"


print_heading "check that nginx is not exposed on the Host"
docker inspect zammad-docker-compose-zammad-nginx-1 | grep HostPort && exit 1
print_heading "Success - nginx is not exposed on the host"

print_heading "check trusted proxy configuration for nginx-proxy-manager"
railsserver_run_command bundle exec rails r 'puts "Trusted Proxies configured as: #{Zammad::TrustedProxies.fetch.inspect}"'
railsserver_run_command bundle exec rails r "Zammad::TrustedProxies.fetch == [Resolv.getaddress('nginx-proxy-manager').to_s] || abort('nginx-proxy-manager is not in trusted proxies')"
print_heading "Success- check trusted proxy configuration for nginx-proxy-manager"