#!/usr/bin/env bash

set -e

: "${AUTOWIZARD_JSON:=''}"
: "${ELASTICSEARCH_HOST:=zammad-elasticsearch}"
: "${ELASTICSEARCH_PORT:=9200}"
: "${MEMCACHED_HOST:=zammad-memcached}"
: "${MEMCACHED_PORT:=11211}"
: "${POSTGRESQL_HOST:=zammad-postgresql}"
: "${POSTGRESQL_PORT:=5432}"
: "${POSTGRESQL_USER:=postgres}"
: "${POSTGRESQL_PASS:=}"
: "${POSTGRESQL_DB:=zammad_production}"
: "${POSTGRESQL_DB_CREATE:=true}"
: "${ZAMMAD_RAILSSERVER_HOST:=zammad-railsserver}"
: "${ZAMMAD_RAILSSERVER_PORT:=3000}"
: "${ZAMMAD_WEBSOCKET_HOST:=zammad-websocket}"
: "${ZAMMAD_WEBSOCKET_PORT:=6042}"
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
  test -f "${ZAMMAD_READY_FILE}" && rm "${ZAMMAD_READY_FILE}"
  rsync -a --delete --exclude 'public/assets/images/*' --exclude 'storage/fs/*' "${ZAMMAD_TMP_DIR}/" "${ZAMMAD_DIR}"
  rsync -a "${ZAMMAD_TMP_DIR}"/public/assets/images/ "${ZAMMAD_DIR}"/public/assets/images

  until (echo > /dev/tcp/"${POSTGRESQL_HOST}"/"${POSTGRESQL_PORT}") &> /dev/null; do
    echo "zammad railsserver waiting for postgresql server to be ready..."
    sleep 5
  done

  cd "${ZAMMAD_DIR}"

  # configure database
  sed -e "s#.*adapter:.*#  adapter: postgresql#g" -e "s#.*database:.*#  database: ${POSTGRESQL_DB}#g" -e "s#.*username:.*#  username: ${POSTGRESQL_USER}#g" -e "s#.*password:.*#  password: ${POSTGRESQL_PASS}\\n  host: ${POSTGRESQL_HOST}\\n#g" < contrib/packager.io/database.yml.pkgr > config/database.yml

  # configure memcache
  sed -i -e "s/.*config.cache_store.*file_store.*cache_file_store.*/    config.cache_store = :dalli_store, '${MEMCACHED_HOST}:${MEMCACHED_PORT}'\\n    config.session_store = :dalli_store, '${MEMCACHED_HOST}:${MEMCACHED_PORT}'/" config/application.rb

  echo "initialising / updating database..."

  # check if database exists / update to new version
  set +e
  bundle exec rake db:migrate &> /dev/null
  DB_MIGRATE="$?"

  # check if database is populated
  if [ "${DB_MIGRATE}" == "0" ]; then
      bundle exec rails r "Setting.set('es_url', 'http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}')" &> /dev/null
      DB_SETTINGS="$?"
  fi
  set -e

  # create database if not exists
  if [ "${DB_MIGRATE}" != "0" ] && [ "${POSTGRESQL_DB_CREATE}" == "true" ]; then
      echo "creating database..."
      bundle exec rake db:create
  fi

  # populate database and create autowizard.json on first install
  if [ "${DB_SETTINGS}" != "0" ]; then
      echo "seeding database..."
      bundle exec rake db:seed

      if [ -n "${AUTOWIZARD_JSON}" ]; then
        echo "${AUTOWIZARD_JSON}" | base64 -d > auto_wizard.json
      fi
  fi

  # es config
  echo "changing settings..."
  bundle exec rails r "Setting.set('es_url', 'http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}')"

  if [ -n "${ELASTICSEARCH_USER}" ] && [ -n "${ELASTICSEARCH_PASS}" ]; then
    bundle exec rails r "Setting.set('es_user', \"${ELASTICSEARCH_USER}\")"
    bundle exec rails r "Setting.set('es_password', \"${ELASTICSEARCH_PASS}\")"
  fi

  until (echo > /dev/tcp/${ELASTICSEARCH_HOST}/${ELASTICSEARCH_PORT}) &> /dev/null; do
    echo "zammad railsserver waiting for elasticsearch server to be ready..."
    sleep 5
  done

  if ! curl -s ${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_cat/indices | grep -q zammad; then
    echo "rebuilding es searchindex..."
    bundle exec rake searchindex:rebuild
  fi

  # chown everything to zammad user
  chown -R "${ZAMMAD_USER}":"${ZAMMAD_USER}" "${ZAMMAD_DIR}"

  # create install ready file
  su -c "echo 'zammad-init' > ${ZAMMAD_READY_FILE}" "${ZAMMAD_USER}"
fi


# zammad nginx
if [ "$1" = 'zammad-nginx' ]; then
  check_zammad_ready

  # configure nginx
  if ! env | grep -q KUBERNETES; then
    sed -e "s#server .*:3000#server ${ZAMMAD_RAILSSERVER_HOST}:${ZAMMAD_RAILSSERVER_PORT}#g" -e "s#server .*:6042#server ${ZAMMAD_WEBSOCKET_HOST}:${ZAMMAD_WEBSOCKET_PORT}#g" -e "s#server_name .*#server_name ${NGINX_SERVER_NAME};#g" -e 's#/var/log/nginx/zammad.\(access\|error\).log#/dev/stdout#g' < contrib/nginx/zammad.conf > /etc/nginx/sites-enabled/default
  fi

  echo "starting nginx..."

  exec /usr/sbin/nginx -g 'daemon off;'
fi


# zammad-railsserver
if [ "$1" = 'zammad-railsserver' ]; then
  test -f /opt/zammad/tmp/pids/server.pid && rm /opt/zammad/tmp/pids/server.pid

  check_zammad_ready

  cd "${ZAMMAD_DIR}"

  echo "starting railsserver..."

  #shellcheck disable=SC2101
  exec gosu "${ZAMMAD_USER}":"${ZAMMAD_USER}" bundle exec rails server puma -b [::] -p "${ZAMMAD_RAILSSERVER_PORT}" -e "${RAILS_ENV}"
fi



# zammad-scheduler
if [ "$1" = 'zammad-scheduler' ]; then
  check_zammad_ready

  cd "${ZAMMAD_DIR}"

  echo "starting scheduler..."

  exec gosu "${ZAMMAD_USER}":"${ZAMMAD_USER}" bundle exec script/scheduler.rb run
fi


# zammad-websocket
if [ "$1" = 'zammad-websocket' ]; then
  check_zammad_ready

  cd "${ZAMMAD_DIR}"

  echo "starting websocket server..."

  exec gosu "${ZAMMAD_USER}":"${ZAMMAD_USER}" bundle exec script/websocket-server.rb -b 0.0.0.0 -p "${ZAMMAD_WEBSOCKET_PORT}" start
fi
