#!/bin/sh

set -e

if [ "$1" = 'zammad-memcached' ]; then
  echo "starting memcached..."

  exec memcached -m "${MEMCACHED_SIZE}"
fi
