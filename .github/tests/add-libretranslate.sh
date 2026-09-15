#!/bin/sh

# shellcheck source=/dev/null
. "$(dirname "$0")/include/functions.sh"

check_stack_start

print_heading "check if libretranslate service is reachable from Zammad"
railsserver_run_command curl http://libretranslate:5000/health
print_heading "Success - libretranslate service is reachable from Zammad"
