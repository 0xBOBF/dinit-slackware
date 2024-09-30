#!/bin/bash
export PATH=/usr/bin:/usr/sbin:/bin:/sbin

set -e

if [ "$1" != "stop" ]; then
  
  # Enable swapping:
  swapon -a
  
  # Mount usbfs only if it is found in /etc/fstab:
  if grep -wq usbfs /proc/filesystems ; then
    if ! grep -wq usbfs /proc/mounts ; then
      if grep -wq usbfs /etc/fstab ; then
        mount /proc/bus/usb
      fi
    fi
  fi

  echo "Mounting auxillary filesystems...."
  mount -avt nonfs,nosmbfs,nocifs,noproc,nosysfs,nodevpts
fi;
