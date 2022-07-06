# note: zammad is currently incompatible to alpine because of:
# https://github.com/docker-library/ruby/issues/113
FROM ruby:3.0.4-slim AS builder

ARG BUILD_DATE
ARG DEBIAN_FRONTEND=noninteractive

ENV GIT_BRANCH stable
ENV GIT_URL ${PROJECT_URL}.git
ENV PROJECT_URL https://github.com/zammad/zammad
ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT true
ENV TAR_GZ_URL ${PROJECT_URL}/archive/${GIT_BRANCH}.tar.gz
ENV ZAMMAD_DIR /opt/zammad
ENV ZAMMAD_READY_FILE ${ZAMMAD_DIR}/tmp/zammad.ready
ENV ZAMMAD_TMP_DIR /tmp/zammad-${GIT_BRANCH}
ENV ZAMMAD_USER zammad

SHELL ["/bin/bash", "-e", "-o", "pipefail", "-c"]

# install zammad
COPY containers/zammad/setup.sh /tmp
RUN chmod +x /tmp/setup.sh; \
    /tmp/setup.sh builder


FROM ruby:3.0.4-slim

ARG BUILD_DATE
ARG DEBIAN_FRONTEND=noninteractive

LABEL org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.name="Zammad" \
      org.label-schema.license="AGPL-3.0" \
      org.label-schema.description="Docker container for Zammad - Data Container" \
      org.label-schema.url="https://zammad.org" \
      org.label-schema.vcs-url="https://github.com/zammad/zammad" \
      org.label-schema.vcs-type="Git" \
      org.label-schema.vendor="Zammad" \
      org.label-schema.schema-version="5.2.1" \
      org.label-schema.docker.cmd="sysctl -w vm.max_map_count=262144;docker-compose up"

ENV GIT_BRANCH stable
ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT true
ENV ZAMMAD_DIR /opt/zammad
ENV ZAMMAD_READY_FILE ${ZAMMAD_DIR}/tmp/zammad.ready
ENV ZAMMAD_TMP_DIR /tmp/zammad-${GIT_BRANCH}
ENV ZAMMAD_USER zammad

COPY containers/zammad/setup.sh /tmp
RUN chmod +x /tmp/setup.sh; \
    /tmp/setup.sh runner

COPY --from=builder ${ZAMMAD_TMP_DIR} ${ZAMMAD_TMP_DIR}
COPY --from=builder /usr/local/bundle /usr/local/bundle

# docker init
COPY containers/zammad/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

USER zammad

WORKDIR ${ZAMMAD_DIR}
