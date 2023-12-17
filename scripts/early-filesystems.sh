#!/bin/bash

set -e

if [ "$1" = start ]; then
  
  PATH=/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin

  # Mount /proc if it is not already mounted:
  if [ ! -d /proc/sys ]; then
    mount -n -t proc proc /proc
  fi

  # Mount /sys if it is not already mounted:
    if [ ! -d /sys/kernel ]; then
      mount -n -t sysfs sysfs /sys
    fi
    
  # Mount efivarfs if it is not already mounted:
  if [ -d /sys/firmware/efi/efivars ]; then
    if ! mount | grep -wq efivarfs ; then
      if [ -r /etc/default/efivarfs ]; then
        . /etc/default/efivarfs
      else
        EFIVARFS=rw
      fi
      case "$EFIVARFS" in
        'rw')
          mount -o rw -t efivarfs none /sys/firmware/efi/efivars
          ;;
        'ro')
          mount -o ro -t efivarfs none /sys/firmware/efi/efivars
          ;;
      esac
    fi
  fi

  # If /run exists, mount a tmpfs on it (unless the
  # initrd has already done so):
  if [ -d /run ]; then
    if ! grep -wq "tmpfs /run tmpfs" /proc/mounts ; then
      mount -n -t tmpfs -o mode=755,size=32M,nodev,nosuid,noexec tmpfs /run
      # various directories within /run:
      mkdir /run/lock /run/udev
    fi
  fi

  # Mount devtmpfs, checking if already mounted:
  if ! grep -wq "devtmpfs /dev devtmpfs" /proc/mounts ; then
    # umount shm if needed
    if grep -wq "tmpfs /dev/shm tmpfs" /proc/mounts ; then
      umount -l /dev/shm
    fi
    
    # umount pts if needed
    if grep -wq "devpts /dev/pts devpts" /proc/mounts ; then
      umount -l /dev/pts
    fi
    mount -n -t devtmpfs -o size=8M devtmpfs /dev
  fi

  # Mount /dev/pts if needed:
  if ! grep -wq "devpts /dev/pts devpts" /proc/mounts ; then
    mkdir -p /dev/pts
    mount -n -t devpts -o mode=0620,gid=5 devpts /dev/pts
  fi

  # Mount /dev/shm if needed:
  if ! grep -wq "tmpfs /dev/shm tmpfs" /proc/mounts ; then
    mkdir -p /dev/shm
    mount -n -t tmpfs tmpfs /dev/shm
  fi

  # Load the kernel loop module. Doing this because its enabled on 
  # slackware by default, presumably to mount loop devices at early boot:
  if modinfo loop ; then
    if ! lsmod | grep -wq "^loop" ; then
      modprobe loop
    fi
  fi

  # Mount the Control Groups filesystem interface.
  # Try using cgroups v2 first, then fallback to v1:
  if grep -wq cgroup2 /proc/filesystems && grep -wq "cgroup_no_v1=all" /proc/cmdline ; then
    if [ -d /sys/fs/cgroup ]; then
      mount -t cgroup2 none /sys/fs/cgroup
    else
      mkdir -p /dev/cgroup
      mount -t cgroup2 none /dev/cgroup
    fi
  elif grep -wq cgroup /proc/filesystems ; then 
    # Set up v1, same as slackware's rc.S:
    if [ -d /sys/fs/cgroup ]; then
      if [ -x /bin/cut -a -x /bin/tail ]; then
        mount -t tmpfs -o mode=0755,size=8M cgroup_root /sys/fs/cgroup
        controllers="$(/bin/cut -f1 /proc/cgroups | /bin/tail -n +2)"
        for i in $controllers; do
          mkdir /sys/fs/cgroup/$i
          mount -t cgroup -o $i $i /sys/fs/cgroup/$i
        done
        unset i controllers
      else
        mkdir -p /dev/cgroup
        mount -t cgroup cgroup /dev/cgroup
      fi
    fi
  fi
fi
