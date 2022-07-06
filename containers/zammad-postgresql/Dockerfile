FROM postgres:9.6.24-alpine

ARG BUILD_DATE

LABEL org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.name="Zammad" \
      org.label-schema.license="AGPL-3.0" \
      org.label-schema.description="Docker container for Zammad - Postgresql" \
      org.label-schema.url="https://zammad.org" \
      org.label-schema.vcs-url="https://github.com/zammad/zammad" \
      org.label-schema.vcs-type="Git" \
      org.label-schema.vendor="Zammad" \
      org.label-schema.schema-version="5.2.1" \
      org.label-schema.docker.cmd="sysctl -w vm.max_map_count=262144;docker-compose up"

SHELL ["/bin/bash", "-e", "-o", "pipefail", "-c"]

# copy backup script
COPY containers/zammad-postgresql/backup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/backup.sh
