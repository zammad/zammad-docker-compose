#!/bin/sh

set -o errexit

start_stack_logs_capture() {
  # Send the logs of the active stack to STDOUT for debugging.
  # This will be active until the stack gets stopped.
  docker compose logs --timestamps --follow &
}

# Print empty lines before and after the heading to find it between the logs.
print_heading() {
  echo ">"
  echo "> $1"
  echo ">"
}

# Run commands in the zammad-railsserver container in a way that also allows the rails stack to start.
railsserver_run_command() {
  docker compose exec --env=AUTOWIZARD_RELATIVE_PATH=tmp/auto_wizard.json --env=DATABASE_URL=postgres://zammad:zammad@zammad-postgresql:5432/zammad_production zammad-railsserver "$@"
}

# Verify that the role Zammad connects with holds none of the privileges that would
#   allow it to read or write files on the database server, or to escalate itself.
check_database_role_is_unprivileged() {
  print_heading "Check that the Zammad database role is unprivileged…"

  docker compose exec --no-TTY zammad-postgresql psql --username postgres --tuples-only --no-align \
    --command "SELECT rolsuper OR rolcreatedb OR rolcreaterole OR rolreplication OR rolbypassrls
               FROM pg_roles WHERE rolname = 'zammad'" | grep -x f

  docker compose exec --no-TTY zammad-postgresql psql --username postgres --tuples-only --no-align \
    --command "SELECT bool_or(pg_has_role('zammad', oid, 'USAGE')) FROM pg_roles
               WHERE rolname IN ('pg_read_server_files', 'pg_write_server_files',
                                 'pg_execute_server_program')" | grep -x f

  print_heading "The Zammad database role is unprivileged :)"
}

check_stack_start() {
  start_stack_logs_capture
  print_heading "wait for zammad to be ready…"
  docker compose wait zammad-init
  docker compose exec zammad-nginx bash -c "curl --retry 30 --retry-delay 1 --retry-connrefused http://localhost:8080 | grep 'Zammad'"
  print_heading "Success - Zammad is up :)"
}