#!/bin/sh

set -o errexit

docker compose up --pull missing --quiet-pull --detach

docker compose cp .github/auto_wizard.json zammad-railsserver:/opt/zammad/tmp
