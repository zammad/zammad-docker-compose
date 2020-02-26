#!/bin/sh
#
# lint bash scripts
#

set -o errexit

REPO_ROOT="$(git rev-parse --show-toplevel)"
TMP_FILE="$(mktemp)"

find "${REPO_ROOT}" -type f -name "*.sh" > "${TMP_FILE}"

while read -r FILE; do
  echo lint "${FILE}"
  shellcheck -x "${FILE}"
done < "${TMP_FILE}"

rm "${TMP_FILE}"
