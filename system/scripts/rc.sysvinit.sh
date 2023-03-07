#!/bin/bash
#
# rc.sysvinit.sh - Support traditional /etc/rc.d/rc.sysvinit scripts

# Source any environment customizations:
. /etc/dinit/system/scripts/env

# If there are SystemV init scripts for this runlevel, run them.
if [ -x /etc/rc.d/rc.sysvinit ]; then
  /etc/rc.d/rc.sysvinit
fi
