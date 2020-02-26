#!/usr/bin/env bash
set -e

# install dependencies
if [ "$1" = 'install' ]; then
  PACKAGES="build-essential curl git libimlib2-dev libpq-dev"
elif [ "$1" = 'run' ]; then
  PACKAGES="curl libimlib2 libpq5 nginx rsync"
fi

apt-get update
apt-get upgrade -y
# shellcheck disable=SC2086
apt-get install -y --no-install-recommends ${PACKAGES}
rm -rf /var/lib/apt/lists/*

# install gosu
if [ "$1" = 'install' ]; then
  curl -s -J -L -o /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture)"
  chmod +x /usr/local/bin/gosu
  gosu nobody true
fi

# install zammad
groupadd -g 1000 "${ZAMMAD_USER}"
useradd -M -d "${ZAMMAD_DIR}" -s /bin/bash -u 1000 -g 1000 "${ZAMMAD_USER}"

if [ "$1" = 'install' ]; then
  cd "$(dirname "${ZAMMAD_TMP_DIR}")"
  curl -s -J -L -O "${TAR_GZ_URL}"
  tar -xzf zammad-"${GIT_BRANCH}".tar.gz
  rm zammad-"${GIT_BRANCH}".tar.gz
  cd "${ZAMMAD_TMP_DIR}"
  bundle install --without test development mysql
  contrib/packager.io/fetch_locales.rb
  sed -e 's#.*adapter: postgresql#  adapter: nulldb#g' -e 's#.*username:.*#  username: postgres#g' -e 's#.*password:.*#  password: \n  host: zammad-postgresql\n#g' < contrib/packager.io/database.yml.pkgr > config/database.yml
  sed -i "/require 'rails\/all'/a require\ 'nulldb'" config/application.rb
  sed -i '/# Use a different logger for distributed setups./a \ \ config.logger = Logger.new(STDOUT)' config/environments/production.rb
  sed -i 's/.*scheduler_\(err\|out\).log.*//g' script/scheduler.rb
  touch db/schema.rb
  bundle exec rake assets:precompile
  rm -r tmp/cache
  chown -R "${ZAMMAD_USER}":"${ZAMMAD_USER}" "${ZAMMAD_TMP_DIR}"
fi
