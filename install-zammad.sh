#!/bin/bash

set -e

# install zammad
echo "installing zammad..."
cd /tmp
git clone --depth 1 -b "${GIT_BRANCH}" "${GIT_URL}"
cp -R /tmp/zammad/* "${ZAMMAD_DIR}"
cp -R /tmp/zammad/.[!.]* "${ZAMMAD_DIR}"
cd "${ZAMMAD_DIR}"
rm -rf /tmp/zammad
bundle install --without test development mysql
contrib/packager.io/fetch_locales.rb
sed -e 's#.*adapter: postgresql#  adapter: nulldb#g' -e 's#.*username:.*#  username: postgres#g' -e 's#.*password:.*#  password: \n  host: postgresql\n#g' < config/database.yml.pkgr > config/database.yml
bundle exec rake assets:precompile
sed -e 's#.*adapter: postgresql#  adapter: postgresql#g' -e 's#.*username:.*#  username: postgres#g' -e 's#.*password:.*#  password: \n  host: postgresql\n#g' < config/database.yml.pkgr > config/database.yml
rm -r tmp/cache
chown -R zammad:zammad "${ZAMMAD_DIR}"
