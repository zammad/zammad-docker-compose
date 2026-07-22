#!/bin/sh

# shellcheck source=/dev/null
. "$(dirname "$0")/include/functions.sh"

check_stack_start

print_heading "Check that zammad-backup did not create an application backup yet, and create one"
docker compose exec zammad-backup sh -c "! find /var/tmp/zammad/ -name \"*zammad_files.tar.gz\" | grep ."
docker compose run --rm --env BACKUP_ONCE=true zammad-backup
print_heading "Backup creation call succeeded :)"

print_heading "Check if zammad-backup created an application backup"
# Provide some debug output for backup tests.
docker compose exec zammad-backup ls -lah /var/tmp/zammad/
docker compose exec zammad-backup sh -c "find /var/tmp/zammad/ -name \"*zammad_files.tar.gz\" | grep ."
print_heading "Application backup successful :)"

print_heading "Check if zammad-backup created a database backup"
# Check that the db dump actually has content in the .gz file to catch cases where pg_dump fails.
docker compose exec zammad-backup sh -c "find /var/tmp/zammad/ -name \"*zammad_db.psql.gz\" -size +1k | grep ."
print_heading "Database backup successful :)"

print_heading "Stop the stack"
docker compose down -t0

print_heading "Copy backup files to restore folder"
docker compose run --rm zammad-backup sh -c "mkdir /var/tmp/zammad/restore && cp /var/tmp/zammad/*gz /var/tmp/zammad/restore/"

print_heading "Start the stack again"
docker compose up -d
check_stack_start

print_heading "Check that restore folder was renamed after successful restore..."
docker compose exec zammad-backup sh -c "[ ! -d /var/tmp/zammad/restore ]"
print_heading "Restore folder was renamed after successful restore..."