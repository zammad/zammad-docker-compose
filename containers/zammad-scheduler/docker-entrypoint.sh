#!/bin/bash

if [ "$1" = 'zammad-scheduler' ]; then
  # wait for zammad process coming up
  until (echo > /dev/tcp/zammad-railsserver/3000) &> /dev/null; do
    echo "scheduler waiting for zammads railsserver to be ready..."
    sleep 2
  done

  echo "scheduler can access raillsserver now..."

  # start scheduler
  cd ${ZAMMAD_DIR}
  bundle exec script/scheduler.rb run
fi
