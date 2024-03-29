#!/bin/sh

BRANCH=${BRANCH:-master}

(
  flock -n 9 || exit 1
  rm -rf /srv_root/docs
  git clone -b $BRANCH $REPOSITORY /srv_root/docs
  cd /srv_root/docs || exit
  mkdocs build --clean --config-file=/srv_root/docs/config.yml
) 9>/var/lock/update.lock
