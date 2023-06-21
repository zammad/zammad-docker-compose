#!/bin/bash

set -e

: "${ZAMMAD_DIR:=/opt/zammad/var}"
: "${BACKUP_DIR:=/var/tmp/zammad}"
: "${ZAMMAD_RAILSSERVER_HOST:=zammad-railsserver}"
: "${ZAMMAD_RAILSSERVER_PORT:=3000}"
: "${POSTGRESQL_HOST:=zammad-postgresql}"
: "${POSTGRESQL_PORT:=5432}"
: "${POSTGRESQL_DB:=zammad_production}"

function check_railsserver_available {
  until (echo > "/dev/tcp/$ZAMMAD_RAILSSERVER_HOST/$ZAMMAD_RAILSSERVER_PORT") &> /dev/null; do
    echo "waiting for railsserver to be ready..."
    sleep 60
  done
}

function zammad_backup {
  TIMESTAMP="$(date +'%Y%m%d%H%M%S')"

  echo "${TIMESTAMP} - backuping zammad..."

  # delete old backups
  if [ -d "${BACKUP_DIR}" ] && [ -n "$(ls "${BACKUP_DIR}")" ]; then
    find "${BACKUP_DIR}"/*_zammad_*.gz -type f -mtime +"${HOLD_DAYS}" -delete
  fi

  if [ "${NO_FILE_BACKUP}" != "yes" ]; then
    # tar files
    tar -czf "${BACKUP_DIR}"/"${TIMESTAMP}"_zammad_files.tar.gz "${ZAMMAD_DIR}"
  fi

  #db backup
  pg_dump --dbname=postgresql://"${POSTGRESQL_USER}:${POSTGRESQL_PASSWORD}@${POSTGRESQL_HOST}:${POSTGRESQL_PORT}/${POSTGRESQL_DB}" | gzip > "${BACKUP_DIR}"/"${TIMESTAMP}"_zammad_db.psql.gz

  echo "backup finished :)"
}

if [ "$1" = 'zammad-backup' ]; then

  check_railsserver_available

  while true; do
    NOW_TIMESTAMP=$(date +%s)
    TOMORROW_DATE=$(date -d@"$((NOW_TIMESTAMP + 24*60*60))" +%Y-%m-%d)
    
    zammad_backup

    NEXT_TIMESTAMP=$(date -d "$TOMORROW_DATE $BACKUP_TIME" +%s)
    NOW_TIMESTAMP=$(date +%s)

    sleep $((NEXT_TIMESTAMP - NOW_TIMESTAMP))
  done
fi

if [ "$1" = 'zammad-backup-once' ]; then
  check_railsserver_available

  zammad_backup
fi

if [ "$1" = 'zammad-backup-db' ]; then
  NO_FILE_BACKUP="yes"

  zammad_backup
fi
