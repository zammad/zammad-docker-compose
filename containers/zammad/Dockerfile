FROM ruby:2.3.1-slim
MAINTAINER Zammad <info@zammad.org>
ARG BUILD_DATE

ENV ZAMMAD_DIR /home/zammad
ENV RAILS_ENV production
ENV RAILS_SERVER puma
ENV GIT_URL https://github.com/zammad/zammad.git
ENV GIT_BRANCH master

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

# install dependencies
RUN apt-get update && apt-get install -y build-essential git-core libpq5 libpq-dev

# install zammad
COPY containers/zammad/install-zammad.sh /tmp
RUN chmod +x /tmp/install-zammad.sh;/bin/bash -l -c /tmp/install-zammad.sh

# cleanup
RUN apt-get remove --purge -y git-core build-essential bzip2 libffi-dev libgdbm3 libssl-dev procps zlib1g-dev && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

