#!/bin/bash

if [ "$1" = 'zammad-backup' ]; then
  # wait for zammad process coming up
  until (echo > /dev/tcp/zammad-railsserver/3000) &> /dev/null; do
    echo "backup waiting for zammads railsserver to be ready..."
    sleep 2
  done

  while true; do
    TIMESTAMP="$(date +'%Y%m%d%H%M%S')"

    echo "${TIMESTAMP} - backuping zammad..."

    # delete old backups
    test -d ${BACKUP_DIR} && find ${BACKUP_DIR}/*_zammad_*.gz -type f -mtime +${HOLD_DAYS} -exec rm {} \;

    # tar files
    tar -czf ${BACKUP_DIR}/${TIMESTAMP}_zammad_files.tar.gz ${ZAMMAD_DIR}

    #db backup
    pg_dump --dbname=postgresql://postgres@zammad-postgresql:5432/zammad_production | gzip > ${BACKUP_DIR}/${TIMESTAMP}_zammad_db.psql.gz

    # wait until next backup
    sleep ${BACKUP_SLEEP}
  done
fi
