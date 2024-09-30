#!/bin/bash

PATH=/usr/bin:/usr/sbin:/bin:/sbin

if [ -r /etc/default/crond ]; then
  . /etc/default/crond
fi

mkdir -p /run/cron
chmod 1777 /run/cron

/usr/sbin/crond -f $CROND_OPTS &
echo "$!" > "$1"
