#!/bin/bash
#
# sysctl.sh - Configure kernel parameters

# Source any environment customizations:
. /etc/dinit/system/scripts/env

# Configure kernel parameters:
if [ -x /sbin/sysctl -a -r /etc/sysctl.conf -a -z "$container" ]; then
  echo "Configuring kernel parameters:  /sbin/sysctl -e --system"
  /sbin/sysctl -e --system
elif [ -x /sbin/sysctl -a -z "$container" ]; then
  echo "Configuring kernel parameters:  /sbin/sysctl -e --system"
  # Don't say "Applying /etc/sysctl.conf" or complain if the file doesn't exist
  /sbin/sysctl -e --system 2> /dev/null | grep -v "Applying /etc/sysctl.conf"
fi
