#!/bin/bash

set -e

function check_railsserver_available {
  # wait for zammad process coming up
  until (echo > /dev/tcp/zammad-railsserver/3000) &> /dev/null; do
    echo "backup waiting for zammads railsserver to be ready..."
    sleep 2
  done
}

function mount_nfs {
  if [ -n "$(env|grep KUBERNETES)" ]; then
    mount -t nfs4 zammad-nfs:/ /home/zammad/tmp
  fi
}

# zammad-railsserver
if [ "$1" = 'zammad-railsserver' ]; then

  # wait for postgres process coming up on zammad-postgresql
  until (echo > /dev/tcp/zammad-postgresql/5432) &> /dev/null; do
    echo "zammad railsserver waiting for postgresql server to be ready..."
    sleep 5
  done

  echo "railsserver can access postgresql server now..."

  rsync -a --delete --exclude 'storage/fs/*' ${ZAMMAD_TMP_DIR}/ ${ZAMMAD_DIR}
  cd ${ZAMMAD_DIR}
  gem update bundler
  bundle install

  mount_nfs

  # db mirgrate
  set +e
  bundle exec rake db:migrate &> /dev/null
  DB_CHECK="$?"
  set -e

  if [ "${DB_CHECK}" != "0" ]; then
    echo "creating db & searchindex..."
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake db:seed
  fi

  # es config
  bundle exec rails r "Setting.set('es_url', 'http://zammad-elasticsearch:9200')"
  bundle exec rake searchindex:rebuild

  chown -R ${ZAMMAD_USER}:${ZAMMAD_USER} ${ZAMMAD_DIR}

  # run zammad
  echo "starting zammad..."
  echo "zammad will be accessable on http://localhost in some seconds"

  if [ "${RAILS_SERVER}" == "puma" ]; then
    exec gosu ${ZAMMAD_USER}:${ZAMMAD_USER} bundle exec puma -b tcp://0.0.0.0:3000 -e ${RAILS_ENV}
  elif [ "${RAILS_SERVER}" == "unicorn" ]; then
    exec gosu ${ZAMMAD_USER}:${ZAMMAD_USER} bundle exec unicorn -p 3000 -c config/unicorn.rb -E ${RAILS_ENV}
  fi
fi


# zammad-scheduler
if [ "$1" = 'zammad-scheduler' ]; then
  check_railsserver_available

  echo "scheduler can access raillsserver now..."

  mount_nfs

  # start scheduler
  cd ${ZAMMAD_DIR}
  exec gosu ${ZAMMAD_USER}:${ZAMMAD_USER} bundle exec script/scheduler.rb run
fi


# zammad-websocket
if [ "$1" = 'zammad-websocket' ]; then
  check_railsserver_available

  echo "websocket server can access raillsserver now..."

  mount_nfs

  cd ${ZAMMAD_DIR}
  exec gosu ${ZAMMAD_USER}:${ZAMMAD_USER} bundle exec script/websocket-server.rb -b 0.0.0.0 start
fi
