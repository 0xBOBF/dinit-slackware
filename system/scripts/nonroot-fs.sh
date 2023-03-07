#!/bin/bash
#
# nonroot-fs.sh - Check and mount non-root filesystems.

# Source any environment customizations:
. /etc/dinit/system/scripts/env

# Check all the non-root filesystems:
if [ ! -r /etc/fastboot -a -z "$container" ]; then
  echo "Checking non-root filesystems:"
  /sbin/fsck $FORCEFSCK -C -R -A -a
fi

# Mount usbfs only if it is found in /etc/fstab:
if [ -z "$container" ]; then
  if grep -wq usbfs /proc/filesystems; then
    if ! grep -wq usbfs /proc/mounts ; then
      if grep -wq usbfs /etc/fstab; then
        /sbin/mount -v /proc/bus/usb
      fi
    fi
  fi
fi

# Mount non-root file systems in fstab, but not NFS or SMB 
# because TCP/IP is not yet configured, and not proc or sysfs
# because those have already been mounted.  Also check that
# devpts is not already mounted before attempting to mount
# it.  With a 2.6.x or newer kernel udev mounts devpts.
if [ -z "$container" ]; then
  echo "Mounting non-root local filesystems:"
  if /bin/grep -wq devpts /proc/mounts ; then
    # This pipe after the mount command is just to convert the new
    # mount verbose output back to the old format that contained
    # more useful information:
    /sbin/mount -a -v -t nonfs,nosmbfs,nocifs,noproc,nosysfs,nodevpts | grep successfully | cut -f 1 -d : | tr -d ' ' | while read dev ; do mount | grep " ${dev} " ; done
  else
    /sbin/mount -a -v -t nonfs,nosmbfs,nocifs,noproc,nosysfs | grep successfully | cut -f 1 -d : | tr -d ' ' | while read dev ; do mount | grep " ${dev} " ; done
  fi
fi
