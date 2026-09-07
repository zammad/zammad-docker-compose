#!/bin/sh

# shellcheck source=/dev/null
. "$(dirname "$0")/include/functions.sh"

check_stack_start

print_heading "check for presence cloudflare tunnel container"
docker compose ps | grep cloudflare-tunnel
print_heading "Success - cloudflare container is present"

print_heading "check that nginx is not exposed on the Host"
docker inspect zammad-docker-compose-zammad-nginx-1 | grep HostPort && exit 1
print_heading "Success - nginx is not exposed on the host"

print_heading "check trusted proxy configuration for cloudflare-tunnel"
# Only the wiring is asserted here, not the resolved address list as in the
#   nginx-proxy-manager test: CI runs the tunnel with an invalid token, so the container
#   exits immediately and never becomes resolvable via docker DNS, which would make
#   Zammad::TrustedProxies.fetch legitimately come back empty.
docker compose exec -T zammad-railsserver printenv RAILS_TRUSTED_PROXIES
docker compose exec -T zammad-railsserver printenv RAILS_TRUSTED_PROXIES | grep -qx cloudflare-tunnel
print_heading "Success - trusted proxy configuration for cloudflare-tunnel"

print_heading "check forwarded scheme in the generated nginx configuration"
docker compose exec zammad-nginx grep 'proxy_set_header X-Forwarded-Proto https;' /etc/nginx/sites-enabled/default
print_heading "Success - nginx forwards the https scheme"
