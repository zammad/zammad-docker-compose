#!/usr/bin/env bash
#
# build zammads docker & docker-compose images

set -o errexit
set -o pipefail

DOCKER_IMAGE="zammad"

echo "Build Zammad Docker image ${DOCKER_IMAGE} for local or ci tests"
docker build --pull --no-cache --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" -t "${DOCKER_IMAGE}-local" -f "containers/${DOCKER_IMAGE}/Dockerfile" .
