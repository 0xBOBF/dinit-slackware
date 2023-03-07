#!/bin/bash
#
# clock-sys.sh - Set the tick and frequency for the system clock.
#
# Default values are: TICK=10000 and FREQ=0

# Source any environment customizations:
. /etc/dinit/system/scripts/env

if [ -z "$container" ]; then
  TICK=10000
  FREQ=0
  # If there's a /etc/default/adjtimex config file, source it to override
  # the default TICK and FREQ:
  if [ -r /etc/default/adjtimex ]; then
    . /etc/default/adjtimex
  fi
  if /sbin/adjtimex --tick $TICK --frequency $FREQ; then
    echo "Setting the system clock rate:  /sbin/adjtimex --tick $TICK --frequency $FREQ"
  else
    echo "Failed to set system clock with adjtimex, possibly invalid parameters? (TICK=$TICK FREQ=$FREQ)"
  fi
fi
