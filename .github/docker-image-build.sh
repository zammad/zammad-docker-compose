#!/usr/bin/env bash
#
# build zammads docker & docker-compose images

set -o errexit
set -o pipefail

DOCKER_IMAGES="zammad zammad-elasticsearch zammad-postgresql"
DOCKER_IMAGE_TAG="ci-snapshot"
DOCKER_REGISTRY="index.docker.io"
DOCKER_REPOSITORY="zammad-docker-compose"

# dockerhub auth
echo "${DOCKER_PASSWORD}" | docker login --username="${DOCKER_USERNAME}" --password-stdin

# shellcheck disable=SC2153
for DOCKER_IMAGE in ${DOCKER_IMAGES}; do
  echo "Build Zammad Docker image ${DOCKER_IMAGE} with version ${DOCKER_IMAGE_TAG} for DockerHubs ${DOCKER_REGISTRY}/${REPO_USER}/${DOCKER_REPOSITORY} repo"
 
  docker build --pull --no-cache --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" -t "${DOCKER_REGISTRY}/${REPO_USER}/${DOCKER_REPOSITORY}:${DOCKER_IMAGE}-${DOCKER_IMAGE_TAG}" -f "containers/${DOCKER_IMAGE}/Dockerfile" .
  docker push "${DOCKER_REGISTRY}/${REPO_USER}/${DOCKER_REPOSITORY}:${DOCKER_IMAGE}-${DOCKER_IMAGE_TAG}"
done

