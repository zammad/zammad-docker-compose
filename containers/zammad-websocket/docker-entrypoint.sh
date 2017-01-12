#!/bin/bash

if [ "$1" = 'zammad-websocket' ]; then

    cd ${ZAMMAD_DIR}
    bundle exec script/websocket-server.rb -b 0.0.0.0 start

fi
