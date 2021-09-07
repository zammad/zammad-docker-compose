#!/usr/bin/env bash
#
# build zammads docker & docker-compose images

set -o errexit
set -o pipefail

. .env

DOCKER_IMAGES="zammad zammad-elasticsearch zammad-postgresql"

# shellcheck disable=SC2153
for DOCKER_IMAGE in ${DOCKER_IMAGES}; do
  docker push "${IMAGE_REPO}:${DOCKER_IMAGE}${VERSION}"
done
