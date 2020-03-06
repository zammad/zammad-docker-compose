#!/usr/bin/env bash
#
# build zammads docker & docker-compose images

set -o errexit
set -o pipefail

DOCKER_IMAGES="zammad zammad-elasticsearch zammad-postgresql"
DOCKER_IMAGE_TAG="ci-snapshot"

# shellcheck disable=SC2153
for DOCKER_IMAGE in ${DOCKER_IMAGES}; do
  echo "Build Zammad Docker image ${DOCKER_IMAGE} with version ${DOCKER_IMAGE_TAG} for local test"
  docker build --pull --no-cache --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" -t "${DOCKER_IMAGE}-${DOCKER_IMAGE_TAG}" -f "containers/${DOCKER_IMAGE}/Dockerfile" .
done

# change images in compose file
sed -i -e 's#image: ${IMAGE_REPO}:##g' -e 's#${VERSION}#-ci-snapsoht#g'< docker-compose.yml
