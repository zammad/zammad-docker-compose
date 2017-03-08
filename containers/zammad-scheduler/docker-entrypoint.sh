#!/bin/bash

if [ "$1" = 'zammad-scheduler' ]; then
  # wait for zammad process coming up
  until echo > /dev/tcp/zammad-railsserver/3000; do
    echo "waiting for zammad to be ready..."
    sleep 2
  done

  # start scheduler
  cd ${ZAMMAD_DIR}
  bundle exec script/scheduler.rb run
fi
