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
#bundle install --without mysql
#rake test:units

#ruby -I test/ test/integration/package_test.rb

bundle exec rails test test/integration/elasticsearch_active_test.rb
bundle exec rails test test/integration/elasticsearch_test.rb
bundle exec rails test test/integration/report_test.rb

EOF

docker-compose logs