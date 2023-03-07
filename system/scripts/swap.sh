#!/bin/bash
#
# swap.sh - Enable swapping
#

# Source any environment customizations:
. /etc/dinit/system/scripts/env

if [ -z "$container" ]; then
  /sbin/swapon -a 2> /dev/null
fi
