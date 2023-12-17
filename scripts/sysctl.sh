#!/bin/bash
export PATH=/usr/bin:/usr/sbin:/bin:/sbin

set -e

if [ "$1" != "stop" ]; then
  if [ -x /sbin/sysctl ]; then
    echo "Configuring kernel parameters: /sbin/sysctl -e --system"
    /sbin/sysctl -e --system
  fi
fi;
