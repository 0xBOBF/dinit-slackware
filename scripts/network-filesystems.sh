#!/bin/bash

# Mount network filesystems such as nfs, cifs, smbfs:
if [ "$1" = start ]; then

  PATH=/usr/bin:/usr/sbin:/bin:/sbin
  
  if grep -v "^#" /etc/fstab | grep -w nfs ; then
    /sbin/mount -a -t nfs
  fi

  if grep -v "^#" /etc/fstab | grep -w cifs ; then
    /sbin/mount -a -t cifs
  fi

  if grep -v "^#" /etc/fstab | grep -w smbfs ; then
    /sbin/mount -a -t smbfs
  fi
fi
