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

check_stack_start() {
  start_stack_logs_capture
  print_heading "wait for zammad to be ready…"
  docker compose wait zammad-init
  docker compose exec zammad-nginx bash -c "curl --retry 30 --retry-delay 1 --retry-connrefused http://localhost:8080 | grep 'Zammad'"
  print_heading "Success - Zammad is up :)"
}