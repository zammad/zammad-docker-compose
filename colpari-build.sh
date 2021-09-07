#!/usr/bin/env bash
#
# build zammads docker & docker-compose images

set -o errexit
set -o pipefail

. .env

DOCKER_IMAGES="zammad zammad-elasticsearch zammad-postgresql"

# shellcheck disable=SC2153
for DOCKER_IMAGE in ${DOCKER_IMAGES}; do
  echo "Build Zammad Docker image ${DOCKER_IMAGE} for local test"
  docker build --pull --no-cache --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" -t "${IMAGE_REPO}:${DOCKER_IMAGE}${VERSION}" -t "${IMAGE_REPO}:${DOCKER_IMAGE}-latest" -f "containers/${DOCKER_IMAGE}/Dockerfile" .
done
