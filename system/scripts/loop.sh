#!/bin/bash
#
# loop.sh - Load the loop device kernel module:
#

# Source any environment customizations:
. /etc/dinit/system/scripts/env

if [ -z "$container" ]; then
  if modinfo loop 1> /dev/null 2> /dev/null ; then
    if ! lsmod | grep -wq "^loop" ; then
      modprobe loop
    fi
  fi
fi
