#!/bin/bash
#
# run zammad tests
#

set -o errexit
set -o pipefail

until (curl -I --silent --fail localhost | grep -iq "HTTP/1.1 200 OK"); do
    echo "wait for zammad to be ready..."
    docker-compose logs
    sleep 15
    clear
done

echo "Zammad is up :)"

# docker exec -i zammad-docker-compose_zammad-railsserver_1 bash <<'EOF'
# set -o errexit
# bundle exec rails test test/unit/user_test.rb 
# EOF
