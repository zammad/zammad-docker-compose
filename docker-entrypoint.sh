#!/bin/bash

ZAMMAD_DIR="/home/zammad"
GIT_URL="https://github.com/zammad/zammad.git"
GIT_BRANCH="develop"
#GIT_URL="https://github.com/monotek/zammad.git"
#GIT_BRANCH="unicorn"
RAILS_SERVER="puma"
RAILS_ENV="production"
FRESH_INSTALL="no"
DEBUG="no"

if [ "$1" = 'zammad' ]; then

    export RAILS_ENV=${RAILS_ENV}

    shopt -s dotglob

    if [ "${FRESH_INSTALL}" == "yes" ]; then
	echo "fresh install requested. deleting everything in ${ZAMMAD_DIR}"
	rm -rf ${ZAMMAD_DIR}/*
    fi

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
	git clone ${GIT_URL}
	mv -f /tmp/zammad/* ${ZAMMAD_DIR}/
	cd ${ZAMMAD_DIR}
	git checkout ${GIT_BRANCH}
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
    echo "zammad will be accessable on http://localhost in some seconds"
    bundle exec script/websocket-server.rb -b 0.0.0.0 start &
    bundle exec script/scheduler.rb start &

    if [ "${RAILS_SERVER}" == "puma" ]; then
	bundle exec puma -b tcp://0.0.0.0:3000
    elif [ "${RAILS_SERVER}" == "unicorn" ]; then
	bundle exec unicorn -p 3000 -c config/unicorn.rb
    fi

    if [ "${DEBUG}" == "yes" ]; then
	# keepalive if error
	while true; do
    	    echo "debugging..."
    	    sleep 600
	done
    fi

fi
