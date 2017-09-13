#!/bin/bash

if [ "$1" = 'zammad-railsserver' ]; then

  # wait for postgres process coming up on zammad-postgresql
  until (echo > /dev/tcp/zammad-postgresql/5432) &> /dev/null; do
    echo "zammad railsserver waiting for postgresql server to be ready..."
    sleep 5
  done

  echo "railsserver can access postgresql server now..."

  rsync -a --delete ${ZAMMAD_TMP_DIR}/ ${ZAMMAD_DIR}

  cd ${ZAMMAD_DIR}

  # update zammad
  gem update bundler
  bundle install

  # db mirgrate
  bundle exec rake db:migrate &> /dev/null

  if [ $? != 0 ]; then
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
