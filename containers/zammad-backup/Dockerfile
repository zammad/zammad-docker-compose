FROM debian
MAINTAINER Zammad <info@zammad.org>
ARG BUILD_DATE

ENV BACKUP_SLEEP 86400
ENV HOLD_DAYS 10
ENV BACKUP_DIR /var/tmp/zammad

LABEL org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.name="Zammad" \
      org.label-schema.license="AGPL-3.0" \
      org.label-schema.description="Docker container for Zammad - Backup container" \
      org.label-schema.url="https://zammad.org" \
      org.label-schema.vcs-url="https://github.com/zammad/zammad" \
      org.label-schema.vcs-type="Git" \
      org.label-schema.vendor="Zammad" \
      org.label-schema.schema-version="1.2" \
      org.label-schema.docker.cmd="sysctl -w vm.max_map_count=262144;docker-compose up"

RUN apt-get update;apt-get -y wget gnupg2 \
  && wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add - \
  && echo "deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main" >> /etc/apt/sources.list.d/postgres.list \
  && apt-get update;apt-get -y install postgresql-client \
  && rm -rf /var/lib/apt/lists/*

# create entrypoint
COPY containers/zammad-backup/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# docker init
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["zammad-backup"]
