#!/bin/sh
#
# run zammad tests
#

set -o errexit

# Send the logs to STDOUT for debugging.
docker compose logs --timestamps --follow &

# Print empty lines before and after the heading to find it between the logs.
print_heading() {
  echo ">"
  echo "> $1"
  echo ">"
}

print_heading "wait for zammad to be ready…"
docker compose wait zammad-init
docker compose exec zammad-nginx bash -c "curl --retry 30 --retry-delay 1 --retry-connrefused http://localhost:8080 | grep 'Zammad'"
print_heading "Success - Zammad is up :)"

# Checking for external connectivity may not always be possible, e.g. in GitLab CI.
if [ -z "$DISABLE_EXTERNAL_TESTS" ]
then
  print_heading "Check external connectivity on exposed port…"
  curl http://localhost:8080 | grep "Zammad"
  print_heading "Zammad is available via external port :)"
fi

print_heading "Execute autowizard…"
docker compose exec --env=AUTOWIZARD_RELATIVE_PATH=tmp/auto_wizard.json --env=DATABASE_URL=postgres://zammad:zammad@zammad-postgresql:5432/zammad_production zammad-railsserver bundle exec rake zammad:setup:auto_wizard
print_heading "Autowizard executed successfully :)"

print_heading "Check DB for AutoWizard user"
docker compose exec --env=DATABASE_URL=postgres://zammad:zammad@zammad-postgresql:5432/zammad_production zammad-railsserver bundle exec rails r "p User.find_by(email: 'info@zammad.org')" | grep 'info@zammad.org'
print_heading "Check DB for AutoWizard user successful :)"

print_heading "Fill DB with some random data"
docker compose exec --env=DATABASE_URL=postgres://zammad:zammad@zammad-postgresql:5432/zammad_production zammad-railsserver bundle exec rails r "FillDb.load(agents: 1,customers: 1,groups: 1,organizations: 1,overviews: 1,tickets: 1)"
print_heading "DB fill successful :)"

print_heading "Check if the Zammad user can write to FS storage"
docker compose exec zammad-railsserver touch storage/test.txt
print_heading "Storage write successful :)"

print_heading "Check if the Zammad user can write /tmp"
docker compose exec zammad-railsserver touch tmp/test.txt
print_heading "Tmp write successful :)"

print_heading "Check if zammad-backup created an application backup"
# Provide some debug output for backup tests.
docker compose exec zammad-backup ls -lah /var/tmp/zammad/
docker compose exec zammad-backup sh -c "find /var/tmp/zammad/ -name \"*zammad_files.tar.gz\" | grep ."
print_heading "Application backup successful :)"

print_heading "Check if zammad-backup created a database backup"
# Check that the db dump actually has content in the .gz file to catch cases where pg_dump fails.
docker compose exec zammad-backup sh -c "find /var/tmp/zammad/ -name \"*zammad_db.psql.gz\" -size +1k | grep ."
print_heading "Database backup successful :)"
