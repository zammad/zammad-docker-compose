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
bundle exec rails test test/integration/aaa_auto_wizard_base_setup_test.rb
bundle exec rails test test/integration/elasticsearch_test.rb
bundle exec rails test test/integration/report_test.rb
bundle exec rails test test/integration/user_agent_test.rb
EOF

docker-compose logs