#!/bin/bash

set -e

function check_zammad_ready {
  until [ -f "${ZAMMAD_DIR}/${ZAMMAD_READY_FILE}" ]; do
    echo "waiting for install or update to be ready..."
    sleep 5
  done
}

# zammad init
if [ "$1" = 'zammad-init' ]; then
  until (echo > /dev/tcp/zammad-postgresql/5432) &> /dev/null; do
    echo "zammad railsserver waiting for postgresql server to be ready..."
    sleep 5
  done

  # install / update zammad
  rsync -av --delete --exclude 'storage/fs/*' --exclude 'public/assets/images/*' ${ZAMMAD_TMP_DIR}/ ${ZAMMAD_DIR}
  rsync -av ${ZAMMAD_TMP_DIR}/public/assets/images/ ${ZAMMAD_DIR}/public/assets/images

  cd ${ZAMMAD_DIR}

  echo "initialising / updating database..."
  # db mirgrate
  set +e
  bundle exec rake db:migrate &> /dev/null
  DB_CHECK="$?"
  set -e

  if [ "${DB_CHECK}" != "0" ]; then
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake db:seed
  fi

  echo "changing settings..."
  # es config
  bundle exec rails r "Setting.set('es_url', 'http://zammad-elasticsearch:9200')"

  until (echo > /dev/tcp/zammad-elasticsearch/9200) &> /dev/null; do
    echo "zammad railsserver waiting for elasticsearch server to be ready..."
    sleep 5
  done

  echo "rebuilding es searchindex..."
  bundle exec rake searchindex:rebuild

  # chown everything to zammad user
  chown -R ${ZAMMAD_USER}:${ZAMMAD_USER} ${ZAMMAD_DIR}

  # create install ready file
  su -c "echo 'zammad-init' > ${ZAMMAD_DIR}/${ZAMMAD_READY_FILE}" ${ZAMMAD_USER}
fi


# zammad nginx
if [ "$1" = 'zammad-nginx' ]; then
  until [ -f "${ZAMMAD_DIR}/${ZAMMAD_READY_FILE}" ] && [ -n "$(grep zammad-railsserver < ${ZAMMAD_DIR}/${ZAMMAD_READY_FILE})" ] && [ -n "$(grep zammad-scheduler < ${ZAMMAD_DIR}/${ZAMMAD_READY_FILE})" ] && [ -n "$(grep zammad-websocket < ${ZAMMAD_DIR}/${ZAMMAD_READY_FILE})" ] ; do
    echo "waiting for all zammad services to start..."
    sleep 5
  done

  rm ${ZAMMAD_DIR}/${ZAMMAD_READY_FILE}

  echo "starting nginx..."

  exec /usr/sbin/nginx -g 'daemon off;'
fi


# zammad-railsserver
if [ "$1" = 'zammad-railsserver' ]; then
  check_zammad_ready

  cd ${ZAMMAD_DIR}

  echo "starting railsserver..."

  echo "zammad-railsserver" >> ${ZAMMAD_DIR}/${ZAMMAD_READY_FILE}

  exec gosu ${ZAMMAD_USER}:${ZAMMAD_USER} bundle exec puma -b tcp://0.0.0.0:3000 -e ${RAILS_ENV}
fi


# zammad-scheduler
if [ "$1" = 'zammad-scheduler' ]; then
  check_zammad_ready

  cd ${ZAMMAD_DIR}

  echo "starting scheduler..."

  echo "zammad-scheduler" >> ${ZAMMAD_DIR}/${ZAMMAD_READY_FILE}

  exec gosu ${ZAMMAD_USER}:${ZAMMAD_USER} bundle exec script/scheduler.rb run
fi


# zammad-websocket
if [ "$1" = 'zammad-websocket' ]; then
  check_zammad_ready

  cd ${ZAMMAD_DIR}

  echo "starting websocket server..."

  echo "zammad-websocket" >> ${ZAMMAD_DIR}/${ZAMMAD_READY_FILE}

  exec gosu ${ZAMMAD_USER}:${ZAMMAD_USER} bundle exec script/websocket-server.rb -b 0.0.0.0 start
fi
