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
bundle install --without mysql
#bundle exec rubocop
# rake db:migrate
# rake db:seed
bundle exec rspec -t ~type:system -t ~searchindex
bundle exec rake db:environment:set RAILS_ENV=test
rake db:reset
rake test:units
ruby -I test/ test/integration/object_manager_test.rb
ruby -I test/ test/integration/package_test.rb
EOF
