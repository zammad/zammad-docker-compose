#!/bin/bash

if [ "$1" = 'zammad-websocket' ]; then
  # wait for zammad process coming up
  until echo > /dev/tcp/zammad-railsserver/3000; do
    echo "waiting for zammad to be ready..."
    sleep 5
  done

  cd ${ZAMMAD_DIR}
  bundle exec script/websocket-server.rb -b 0.0.0.0 start
fi
