#!/bin/bash
#
# run zammad tests
#

set -o errexit
set -o pipefail

until (curl -I --silent --fail localhost | grep -iq zammad_session); do
    echo "wait for zammad to be ready..."
    sleep 15
done

docker exec -i zammad-docker-compose_zammad-railsserver_1 bash <<'EOF'
set -o errexit
bundle exec rails test test/unit/user_test.rb 

EOF

docker-compose logs