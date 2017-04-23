#!/bin/bash

if [ "$1" = 'zammad-websocket' ]; then
  # wait for zammad process coming up
  until (echo > /dev/tcp/zammad-railsserver/3000) &> /dev/null; do
    echo "websocket server waiting for zammads railsserver to be ready..."
    sleep 5
  done

  echo "websocket server can access raillsserver now..."

  cd ${ZAMMAD_DIR}
  bundle exec script/websocket-server.rb -b 0.0.0.0 start
fi
