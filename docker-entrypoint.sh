#!/bin/bash

ZAMMAD_DIR="/home/zammad"
RAILS_SERVER="puma"
RAILS_ENV="production"
DEBUG="no"

if [ "$1" = 'zammad' ]; then

    export RAILS_ENV=${RAILS_ENV}

    cd ${ZAMMAD_DIR}
    rake db:migrate &> /dev/null

    if [ $? != 0 ]; then
	echo "creating db, assets, searchindex..."
	rake db:create
	rake db:migrate
	rake db:seed
	rake assets:precompile
	rails r "Setting.set('es_url', 'http://elasticsearch:9200')"
	rake searchindex:rebuild
    fi

    # delete logs & pids
    rm ${ZAMMAD_DIR}/log/*
    rm ${ZAMMAD_DIR}/tmp/pids/*

    # run zammad
    echo "starting zammad..."
    echo "zammad will be accessable on http://localhost in some seconds"
    bundle exec script/websocket-server.rb -b 0.0.0.0 start &
    bundle exec script/scheduler.rb start &

    if [ "${RAILS_SERVER}" == "puma" ]; then
	bundle exec puma -b tcp://0.0.0.0:3000 -e ${RAILS_ENV}
    elif [ "${RAILS_SERVER}" == "unicorn" ]; then
	bundle exec unicorn -p 3000 -c config/unicorn.rb -E ${RAILS_ENV}
    fi

    if [ "${DEBUG}" == "yes" ]; then
	# keepalive if error
	while true; do
    	    echo "debugging..."
    	    sleep 600
	done
    fi

fi
