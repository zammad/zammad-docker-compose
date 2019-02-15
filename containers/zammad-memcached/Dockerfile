FROM memcached:alpine
MAINTAINER Zanmmad <info@zammad.org>

ENV MEMCACHED_SIZE 256M

LABEL org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.name="Zammad" \
      org.label-schema.license="AGPL-3.0" \
      org.label-schema.description="Docker container for Zammad - Memcached Container" \
      org.label-schema.url="https://zammad.org" \
      org.label-schema.vcs-url="https://github.com/zammad/zammad" \
      org.label-schema.vcs-type="Git" \
      org.label-schema.vendor="Zammad" \
      org.label-schema.schema-version="2.9.0" \
      org.label-schema.docker.cmd="sysctl -w vm.max_map_count=262144;docker-compose up"

# docker init
USER root
COPY containers/zammad-memcached/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
USER memcache
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["zammad-memcached"]
