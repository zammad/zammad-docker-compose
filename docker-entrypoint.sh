#!/bin/bash

ZAMMAD_DIR="/home/zammad"
DEBUG="no"

export RAILS_ENV="production"

if [ "$1" = 'zammad' ]; then

    # get zammad
    if [ -f ${ZAMMAD_DIR}/config/database.yml ]; then
	echo "updating zammad..."
	cd ${ZAMMAD_DIR}
	git pull
	bundle update
	rake db:migrate
    else
	echo "installing zammad..."
	cd /tmp
	git clone https://github.com/zammad/zammad.git
	shopt -s dotglob
	mv -f /tmp/zammad/* ${ZAMMAD_DIR}/
	shopt -u dotglob
	cd ${ZAMMAD_DIR}
	bundle install --without test development
	sed -e 's#.*username:.*#  username: postgres#g' -e 's#.*password:.*#  password: \n  host: postgresql\n#g' < config/database.yml.pkgr > config/database.yml
	rake db:drop
	rake db:create
	rake db:migrate
	rake db:seed
	rake assets:precompile
	rails r "Setting.set('es_url', 'http://elasticsearch:9200')"
    fi

    # delte logs & pids
    rm ${ZAMMAD_DIR}/log/*
    rm ${ZAMMAD_DIR}/tmp/pids/*

    # run zammad
    echo "starting zammad..."
    script/websocket-server.rb -b 0.0.0.0 start &
    script/scheduler.rb start &
    rails s -p 3000 -b 0.0.0.0

    if [ "${DEBUG}" == "yes" ]; then
	# keepalive if error
	while true; do
    	    echo "debugging..."
    	    sleep 600
	done
    fi

fi
