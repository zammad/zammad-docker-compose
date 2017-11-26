#!/bin/bash

set -e

if [ "$1" = 'zammad-nfs' ]; then
  echo "creating nfs dir"

  test -d ${NFS_DIR}/data || mkdir -p ${NFS_DIR}/data
  test -d ${NFS_DIR}/uploads || mkdir -p ${NFS_DIR}/uploads
  chmod -R 777 ${NFS_DIR}

  echo "create nfs exports"
  echo "# NFS Export for Zammad" > /etc/exports
  echo "${NFS_DIR} *(rw,sync,no_subtree_check,fsid=0,no_root_squash)" >> /etc/exports
  echo "${NFS_DIR}/data *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
  echo "${NFS_DIR}/uploads *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports

  exec runsvdir /etc/sv
fi
