#!/bin/bash
#
# kernel-fs.sh - Mounts for the kernel's virtual filesystems
#

# Source any environment customizations:
. /etc/dinit/system/scripts/env

# Mount /proc if it is not already mounted:
if [ ! -d /proc/sys -a -z "$container" ]; then
  /sbin/mount -v proc /proc -n -t proc 2> /dev/null
fi

# Mount /sys if it is not already mounted:
if [ ! -d /sys/kernel -a -z "$container" ]; then
  /sbin/mount -v sysfs /sys -n -t sysfs 2> /dev/null
fi

# If /run exists, mount a tmpfs on it (unless the
# initrd has already done so):
if [ -d /run -a -z "$container" ]; then
  if ! grep -wq "tmpfs /run tmpfs" /proc/mounts ; then
    /sbin/mount -v -n -t tmpfs tmpfs /run -o mode=0755,size=32M,nodev,nosuid,noexec
  fi
fi
