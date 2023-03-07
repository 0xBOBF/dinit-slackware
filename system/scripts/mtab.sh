#!/bin/bash
#
# mtab.sh - Handle the /etc/mtab file

# Source any environment customizations:
. /etc/dinit/system/scripts/env

# If /etc/mtab is a symlink (probably to /proc/mounts) then we don't want to mess with it.
if [ ! -L /etc/mtab -o ! -r /etc/mtab ]; then
  # /etc/mtab is a file (or doesn't exist), so we'll handle it the old way:
  # Any /etc/mtab that exists here is old, so we start with a new one:
  /bin/rm -f /etc/mtab{,~,.tmp} && /bin/touch /etc/mtab
  if [ -z "$container" ]; then
    # Add /, /proc, /sys, and /dev/shm mounts to /etc/mtab:
    /sbin/mount -f -w /
    if [ -d /proc/sys ]; then
      /sbin/mount -f -t proc proc /proc
    fi
    if [ -d /sys/bus ]; then
      /sbin/mount -f -t sysfs sysfs /sys
    fi
    if grep -q '^[^ ]\+ /dev/shm ' /proc/mounts 2> /dev/null ; then
      /sbin/mount -f -t tmpfs tmpfs /dev/shm
    fi
  fi
fi
