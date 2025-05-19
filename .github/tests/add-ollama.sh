#!/bin/sh

# shellcheck source=/dev/null
. "$(dirname "$0")/include/functions.sh"

check_stack_start

print_heading "check if ollama service is reachable from Zammad"
railsserver_run_command curl http://ollama:11434/api/version
print_heading "Success - ollama service is reachable from Zammad"
