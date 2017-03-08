#!/bin/bash

set -ex

# create zammad user
useradd -M -d "${ZAMMAD_DIR}" -s /bin/bash zammad

# git clone zammad
cd $(dirname "${ZAMMAD_DIR}")
git clone --depth 1 -b "${GIT_BRANCH}" "${GIT_URL}"

# install zammad
cd "${ZAMMAD_DIR}"
bundle install --without test development mysql

# fetch locales
contrib/packager.io/fetch_locales.rb

# set nulldb database adapter for assets precompile
sed -e 's#.*adapter: postgresql#  adapter: nulldb#g' -e 's#.*username:.*#  username: postgres#g' -e 's#.*password:.*#  password: \n  host: zammad-postgresql\n#g' < config/database.yml.pkgr > config/database.yml

# assets precompile
bundle exec rake assets:precompile

# set postgresql database adapter
sed -e 's#.*adapter: postgresql#  adapter: postgresql#g' -e 's#.*username:.*#  username: postgres#g' -e 's#.*password:.*#  password: \n  host: zammad-postgresql\n#g' < config/database.yml.pkgr > config/database.yml

# delete assets precompile cache
rm -r tmp/cache

# set user & group to zammad
chown -R zammad:zammad "${ZAMMAD_DIR}"
