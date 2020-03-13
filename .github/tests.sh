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

#curl -I --silent --fail --show-error "http://localhost/#getting_started/auto_wizard/docker_compose_token" > /dev/null
curl  "http://localhost/#getting_started/auto_wizard/docker_compose_token"

echo 
echo "Autowizard executed successful :)"
echo 

sleep 10

docker exec zammad-docker-compose_zammad-railsserver_1 "rails c 'FillDB.load(agents: 50,customers: 1000,groups: 20,organizations: 40,overviews: 5,tickets: 100)'" 

echo
echo "create user via api"
echo
curl --silent --fail --show-error -u info@zammad.org:Zammad -H "Content-Type: application/json" -X POST -d '{"firstname":"Bob","lastname":"Smith","email":"testuser@example.com","roles":["Customer"],"password":"some_password"}' 'http://localhost/api/v1/users'

echo 
echo "search user"
echo
curl --silent --fail --show-error -u info@zammad.org:Zammad 'http://localhost/api/v1/users/search?query=Smith&limit=10&expand=true'

echo
echo "create ticket"
echo
curl --silent --fail --show-error -u info@zammad.org:Zammad -H "Content-Type: application/json" -X POST -d '{"title":"Help me!","group": "Users","article":{"subject":"some subject","body":"some message","type":"note","internal":false},"customer":"testuser@example.com","note": "some note"}' 'http://localhost/api/v1/tickets'




