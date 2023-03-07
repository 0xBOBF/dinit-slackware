#!/bin/bash
#
# rc.modules.sh - Support traditional /etc/rc.d/rc.modules 
# scripts for loading kernel modules.

# Source any environment customizations:
. /etc/dinit/system/scripts/env

# Run the kernel module script.  This updates the module dependencies and
# also supports manually loading kernel modules through rc.modules.local.
if [ -x /etc/rc.d/rc.modules -a -z "$container" ]; then
  /etc/rc.d/rc.modules
fi
