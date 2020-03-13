#!/bin/bash
#
# run zammad tests
#

set -o errexit
set -o pipefail

docker-compose logs --timestamps --follow &

until (curl -I --silent --fail localhost | grep -iq "HTTP/1.1 200 OK"); do
    echo "wait for zammad to be ready..."
    sleep 15
done

sleep 30

echo
echo "Success - Zammad is up :)"
echo
echo "Execute autowizard..."
echo

curl -I --silent --fail --show-error "http://localhost/#getting_started/auto_wizard/docker_compose_token" > /dev/null

echo 
echo "Autowizard executed successful :)"
echo 

echo 
echo "Fill db with some random data..."
echo

docker exec zammad-docker-compose_zammad-railsserver_1 rails r "FillDB.load(agents: 10,customers: 10,groups: 10,organizations: 10,overviews: 10,tickets: 10)"

echo 
echo "Fill DB executed successful :)"
echo 
