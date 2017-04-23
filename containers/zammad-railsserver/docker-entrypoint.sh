#!/bin/bash

if [ "$1" = 'zammad-railsserver' ]; then

  # wait for postgres process coming up on zammad-postgresql
  until (echo > /dev/tcp/zammad-postgresql/5432) &> /dev/null; do
    echo "zammad railsserver waiting for postgresql server to be ready..."
    sleep 5
  done

  echo "railsserver can access postgresql server now..."

  cd ${ZAMMAD_DIR}
  bundle exec rake db:migrate &> /dev/null

  if [ $? != 0 ]; then
    echo "creating db & searchindex..."
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake db:seed
    bundle exec rails r "Setting.set('es_url', 'http://zammad-elasticsearch:9200')"
    bundle exec rake searchindex:rebuild
  fi

  # delete logs
  find ${ZAMMAD_DIR}/log -iname *.log -exec rm {} \;

  # run zammad
  echo "starting zammad..."
  echo "zammad will be accessable on http://localhost in some seconds"

  if [ "${RAILS_SERVER}" == "puma" ]; then
    bundle exec puma -b tcp://0.0.0.0:3000 -e ${RAILS_ENV}
    elif [ "${RAILS_SERVER}" == "unicorn" ]; then
    bundle exec unicorn -p 3000 -c config/unicorn.rb -E ${RAILS_ENV}
  fi

fi
