#!/bin/bash

ZAMMAD_DIR="/home/zammad"
GIT_URL="https://github.com/zammad/zammad.git"
GIT_BRANCH="develop"
#GIT_URL="https://github.com/monotek/zammad.git"
#GIT_BRANCH="unicorn"

# install zammad
echo "installing zammad..."
cd /tmp
git clone --depth 1 -b ${GIT_BRANCH} ${GIT_URL}
cp -R /tmp/zammad/* ${ZAMMAD_DIR}
cp -R /tmp/zammad/.[!.]* ${ZAMMAD_DIR}
cd ${ZAMMAD_DIR}
rm -rf /tmp/zammad
bundle install --without test development mysql
sed -e 's#.*username:.*#  username: postgres#g' -e 's#.*password:.*#  password: \n  host: postgresql\n#g' < config/database.yml.pkgr > config/database.yml
chown -R zammad:zammad /home/zammad/
