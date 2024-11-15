#!/bin/bash
#
# run zammad tests
#

set -o errexit
set -o pipefail

docker compose logs --timestamps --follow &

echo
echo "wait for zammad to be ready..."
echo

curl --silent --retry 120 --retry-delay 1 --retry-connrefused http://localhost:8080 | grep "Zammad"

echo
echo "Success - Zammad is up :)"
echo

echo
echo "Execute autowizard..."
echo

docker compose exec --env=AUTOWIZARD_RELATIVE_PATH=tmp/auto_wizard.json --env=DATABASE_URL=postgres://zammad:zammad@zammad-postgresql:5432/zammad_production zammad-railsserver bundle exec rake zammad:setup:auto_wizard

echo
echo "Autowizard executed successful :)"
echo

echo
echo "Check DB for AutoWizard user"
echo

docker compose exec --env=DATABASE_URL=postgres://zammad:zammad@zammad-postgresql:5432/zammad_production zammad-railsserver bundle exec rails r "p User.find_by(email: 'info@zammad.org')" | grep 'info@zammad.org'

echo
echo "Check DB for AutoWizard user successfull :)"
echo

echo
echo "Fill DB with some random data"
echo

docker compose exec --env=DATABASE_URL=postgres://zammad:zammad@zammad-postgresql:5432/zammad_production zammad-railsserver bundle exec rails r "FillDb.load(agents: 1,customers: 1,groups: 1,organizations: 1,overviews: 1,tickets: 1)"

echo
echo "DB fill successful :)"
echo

echo
echo "Check if the Zammad user can write to FS storage"
echo

docker compose exec zammad-railsserver touch storage/test.txt

echo
echo "Storage write successful :)"
echo
