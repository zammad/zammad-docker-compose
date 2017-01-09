#!/bin/bash

if [ "$1" = 'zammad' ]; then

    cd ${ZAMMAD_DIR}
    bundle exec rake db:migrate &> /dev/null

    if [ $? != 0 ]; then
	echo "creating db & searchindex..."
	bundle exec rake db:create
	bundle exec rake db:migrate
	bundle exec rake db:seed
	bundle exec rails r "Setting.set('es_url', 'http://elasticsearch:9200')"
	bundle exec rake searchindex:rebuild
    fi

    # delete logs & pids
    rm ${ZAMMAD_DIR}/log/*.log
    rm ${ZAMMAD_DIR}/tmp/pids/*.pid

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

fi
