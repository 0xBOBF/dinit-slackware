#!/bin/bash
#
# lvm.sh - Initialize the Logical Volume Manager.
# This won't start unless we find /etc/lvmtab (LVM1) or
# /etc/lvm/backup/ (LVM2).  This is created by /sbin/vgscan, so to
# use LVM you must run /sbin/vgscan yourself the first time (and
# create some VGs and LVs).

# Source any environment customizations:
. /etc/dinit/system/scripts/env

if [ -z "$container" ]; then
  # Create LVM lock/run directories:
  mkdir -p -m 0700 /run/lvm /run/lock /run/lock/lvm
  if [ -r /etc/lvmtab -o -d /etc/lvm/backup ]; then
    echo "Initializing LVM (Logical Volume Manager):"
    # Check for device-mapper support.
    if ! grep -wq device-mapper /proc/devices ; then
      # Try to load a device-mapper kernel module:
      /sbin/modprobe -q dm-mod
    fi
    # Scan for new volume groups:
    /sbin/vgscan --mknodes --ignorelockingfailure 2> /dev/null
    if [ $? = 0 ]; then
      # Make volume groups available to the kernel.
      # This should also make logical volumes available.
      /sbin/vgchange -ay --ignorelockingfailure
    fi
  fi
fi
