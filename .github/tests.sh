#!/bin/bash
#
# run zammad tests
#

set -o errexit
set -o pipefail

docker-compose logs --timestamps --follow &

until (curl -I --silent --fail localhost:8080 | grep -iq "HTTP/1.1 200 OK"); do
    echo "wait for zammad to be ready..."
    sleep 15
done

sleep 30

echo
echo "Success - Zammad is up :)"
echo

echo
echo "Execute autowizard..."
echo

docker exec zammad-docker-compose_zammad-railsserver_1 rake zammad:setup:auto_wizard

echo
echo "Autowizard executed successful :)"
echo


echo
echo "Fill DB with some random data"
docker exec zammad-docker-compose_zammad-railsserver_1 rails r "FillDb.load(agents: 1,customers: 1,groups: 1,organizations: 1,overviews: 1,tickets: 1)"

echo
echo "DB fill successful :)"
echo
