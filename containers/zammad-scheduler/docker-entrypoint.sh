#!/bin/bash

if [ "$1" = 'zammad-scheduler' ]; then

    # start scheduler
    cd ${ZAMMAD_DIR}
    bundle exec script/scheduler.rb run

fi
