#!/bin/bash

set -e

: "${ELASTICSEARCH_HOST:=zammad-elasticsearch}"
: "${MEMCACHED_HOST:=zammad-memcached}"
: "${POSTGRESQL_HOST:=zammad-postgresql}"
: "${POSTGRESQL_USER:=postgres}"
: "${POSTGRESQL_PASS:=}"
: "${POSTGRESQL_DB:=zammad_production}"
: "${ZAMMAD_RAILSSERVER_HOST:=zammad-railsserver}"
: "${ZAMMAD_WEBSOCKET_HOST:=zammad-websocket}"
: "${NGINX_SERVER_NAME:=_}"

function check_zammad_ready {
  sleep 15
  until [ -f "${ZAMMAD_READY_FILE}" ]; do
    echo "waiting for init container to finish install or update..."
    sleep 10
  done
}

# zammad init
if [ "$1" = 'zammad-init' ]; then
  # install / update zammad
  test -f ${ZAMMAD_READY_FILE} && rm ${ZAMMAD_READY_FILE}
  rsync -a --delete --exclude 'storage/fs/*' --exclude 'public/assets/images/*' ${ZAMMAD_TMP_DIR}/ ${ZAMMAD_DIR}
  rsync -a ${ZAMMAD_TMP_DIR}/public/assets/images/ ${ZAMMAD_DIR}/public/assets/images

  until (echo > /dev/tcp/${POSTGRESQL_HOST}/5432) &> /dev/null; do
    echo "zammad railsserver waiting for postgresql server to be ready..."
    sleep 5
  done

  cd ${ZAMMAD_DIR}

  # configure database & cache
  sed -e "s#.*adapter:.*#  adapter: postgresql#g" -e "s#.*database:.*#  database: ${POSTGRESQL_DB}#g" -e "s#.*username:.*#  username: ${POSTGRESQL_USER}#g" -e "s#.*password:.*#  password: ${POSTGRESQL_PASS}\n  host: ${POSTGRESQL_HOST}\n#g" < config/database.yml.pkgr > config/database.yml
  sed -i -e "s/.*config.cache_store.*file_store.*cache_file_store.*/    config.cache_store = :dalli_store, '${MEMCACHED_HOST}:11211'\n    config.session_store = :dalli_store, '${MEMCACHED_HOST}:11211'/" config/application.rb

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
  bundle exec rails r "Setting.set('es_url', 'http://${ELASTICSEARCH_HOST}:9200')"

  if [ -n "${ELASTICSEARCH_USER}" ] && [ -n "${ELASTICSEARCH_PASS}" ]; then
    bundle exec rails r "Setting.set('es_user', \"${ELASTICSEARCH_USER}\")"
    bundle exec rails r "Setting.set('es_password', \"${ELASTICSEARCH_PASS}\")"
  fi

  until (echo > /dev/tcp/${ELASTICSEARCH_HOST}/9200) &> /dev/null; do
    echo "zammad railsserver waiting for elasticsearch server to be ready..."
    sleep 5
  done

  echo "rebuilding es searchindex..."
  bundle exec rake searchindex:rebuild

  # chown everything to zammad user
  chown -R ${ZAMMAD_USER}:${ZAMMAD_USER} ${ZAMMAD_DIR}

  # create install ready file
  su -c "echo 'zammad-init' > ${ZAMMAD_READY_FILE}" ${ZAMMAD_USER}
fi

# zammad nginx
if [ "$1" = 'zammad-nginx' ]; then
  check_zammad_ready

  # configure nginx
  if [ -z "$(env|grep KUBERNETES)" ]; then
    sed -e "s#server .*:3000#server ${ZAMMAD_RAILSSERVER_HOST}:3000#g" -e "s#server .*:6042#server ${ZAMMAD_WEBSOCKET_HOST}:6042#g" -e "s#server_name .*#server_name ${NGINX_SERVER_NAME};#g" -e 's#/var/log/nginx/zammad.\(access\|error\).log#/dev/stdout#g' < contrib/nginx/zammad.conf > /etc/nginx/sites-enabled/default
  fi

  echo "starting nginx..."

  exec /usr/sbin/nginx -g 'daemon off;'
fi


# zammad-railsserver
if [ "$1" = 'zammad-railsserver' ]; then
  check_zammad_ready

  cd ${ZAMMAD_DIR}

  echo "starting railsserver..."

  exec gosu ${ZAMMAD_USER}:${ZAMMAD_USER} bundle exec rails server puma -b [::] -p 3000 -e ${RAILS_ENV}
fi


# zammad-scheduler
if [ "$1" = 'zammad-scheduler' ]; then
  check_zammad_ready

  cd ${ZAMMAD_DIR}

  echo "starting scheduler..."

  exec gosu ${ZAMMAD_USER}:${ZAMMAD_USER} bundle exec script/scheduler.rb run
fi


# zammad-websocket
if [ "$1" = 'zammad-websocket' ]; then
  check_zammad_ready

  cd ${ZAMMAD_DIR}

  echo "starting websocket server..."

  exec gosu ${ZAMMAD_USER}:${ZAMMAD_USER} bundle exec script/websocket-server.rb -b 0.0.0.0 -p 6042 start
fi
