FROM ruby:2.4.4-slim
MAINTAINER Zammad <info@zammad.org>
ARG BUILD_DATE

ENV ZAMMAD_DIR /opt/zammad
ENV ZAMMAD_USER zammad
ENV RAILS_ENV production
ENV RAILS_SERVER puma
ENV PROJECT_URL https://github.com/zammad/zammad
ENV GIT_URL ${PROJECT_URL}.git
ENV GIT_BRANCH stable
ENV ZAMMAD_TMP_DIR /tmp/zammad-${GIT_BRANCH}
ENV TAR_GZ_URL ${PROJECT_URL}/archive/${GIT_BRANCH}.tar.gz
ENV GOSU_VERSION 1.10
ENV ZAMMAD_READY_FILE ${ZAMMAD_DIR}/tmp/zammad.ready

LABEL org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.name="Zammad" \
      org.label-schema.license="AGPL-3.0" \
      org.label-schema.description="Docker container for Zammad - Data Container" \
      org.label-schema.url="https://zammad.org" \
      org.label-schema.vcs-url="https://github.com/zammad/zammad" \
      org.label-schema.vcs-type="Git" \
      org.label-schema.vendor="Zammad" \
      org.label-schema.schema-version="1.2" \
      org.label-schema.docker.cmd="sysctl -w vm.max_map_count=262144;docker-compose up"

# install dependencies & gosu
RUN BUILD_DEPENDENCIES="build-essential ca-certificates curl dirmngr git gnupg2 libffi-dev libpq5 libpq-dev nginx rsync" \
    set -ex \
	  && apt-get update && apt-get install -y --no-install-recommends ${BUILD_DEPENDENCIES} && rm -rf /var/lib/apt/lists/* \
	  && curl -s -J -L -o /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture)" \
	  && curl -s -J -L -o /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture).asc" \
	  && export GNUPGHOME="$(mktemp -d)" \
	  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	  && rm -rf "${GNUPGHOME}" /usr/local/bin/gosu.asc \
	  && chmod +x /usr/local/bin/gosu \
	  && gosu nobody true

# install zammad
RUN groupadd -g 1000 ${ZAMMAD_USER} \
    && useradd -M -d ${ZAMMAD_DIR} -s /bin/bash -u 1000 -g 1000 ${ZAMMAD_USER} \
    && cd $(dirname ${ZAMMAD_TMP_DIR}) \
    && curl -s -J -L -O "${TAR_GZ_URL}" \
    && tar -xzf zammad-${GIT_BRANCH}.tar.gz \
    && rm zammad-${GIT_BRANCH}.tar.gz \
    && cd ${ZAMMAD_TMP_DIR} \
    && bundle install --without test development mysql \
    && contrib/packager.io/fetch_locales.rb \
    && sed -e 's#.*adapter: postgresql#  adapter: nulldb#g' -e 's#.*username:.*#  username: postgres#g' -e 's#.*password:.*#  password: \n  host: zammad-postgresql\n#g' < contrib/packager.io/database.yml.pkgr > config/database.yml \
    && sed -i '/# Use a different logger for distributed setups./a \ \ config.logger = Logger.new(STDOUT)' config/environments/production.rb \
    && sed -i 's/.*scheduler_\(err\|out\).log.*//g' script/scheduler.rb \
    && bundle exec rake assets:precompile \
    && rm -r tmp/cache \
    && chown -R ${ZAMMAD_USER}:${ZAMMAD_USER} ${ZAMMAD_TMP_DIR}

# docker init
COPY containers/zammad/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

WORKDIR ${ZAMMAD_DIR}
