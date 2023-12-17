#!/bin/bash

set -e

MOUNTPOINT="/sys/fs/fuse/connections"

if [ "$1" != "stop" ]; then
  # Load the kernel module, if needed:
  if ! grep -wq fuse /proc/filesystems; then
    modprobe fuse
  fi
  if grep -wq fusectl /proc/filesystems && ! grep -wq "$MOUNTPOINT" /proc/mounts; then
    mount -t fusectl fusectl "$MOUNTPOINT"
  fi
else
  # Stop
  if grep -wq "$MOUNTPOINT" /proc/mounts; then
    umount "$MOUNTPOINT"
  fi
  if grep -wq "^fuse" /proc/modules; then
    modprobe -r fuse
  fi
fi
