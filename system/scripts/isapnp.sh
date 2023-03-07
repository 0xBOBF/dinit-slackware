#!/bin/bash
#
# isapnp.sh - Configure ISA Plug-and-Play devices

# Source any environment customizations:
. /etc/dinit/system/scripts/env

if [ -r /etc/isapnp.conf -a -z "$container" ]; then
  if [ -x /sbin/isapnp ]; then
    /sbin/isapnp /etc/isapnp.conf
  fi
fi
