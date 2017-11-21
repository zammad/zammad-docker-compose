#!/bin/bash

set -e

if [ "$1" = 'zammad-memcached' ]; then
  exec memcached -m ${MEMCACHED_SIZE}
fi
