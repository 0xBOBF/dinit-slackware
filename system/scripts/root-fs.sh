#!/bin/bash
#
# root-fs.sh - Check root filesystems and remount rw.

# Source any environment customizations:
. /etc/dinit/system/scripts/env

# Test to see if the root partition is read-only, like it ought to be.
if [ -z "$container" ]; then
  READWRITE=no
  if touch /fsrwtestfile 2>/dev/null; then
    rm -f /fsrwtestfile
    READWRITE=yes
  else
    echo "Testing root filesystem status:  read-only filesystem"
  fi
fi

# See if a forced filesystem check was requested at shutdown:
if [ -r /etc/forcefsck -a -z "$container" ]; then
  FORCEFSCK="-f"
fi

# Check the root filesystem:
if [ -z "$container" ]; then
  # If we're using F2FS for the root filesystem, don't check it as it doesn't
  # allow checking a read-only filesystem:
  if grep -q ' / f2fs ' /proc/mounts ; then
    echo "Remounting root device with read-write enabled."
    /sbin/mount -w -v -n -o remount /
  elif [ ! $READWRITE = yes ]; then
    # Check the root filesystem:
    RETVAL=0
    if [ ! -r /etc/fastboot ]; then
      echo "Checking root filesystem:"
      /sbin/fsck $FORCEFSCK -C -a /
      RETVAL=$?
    fi
    # An error code of 2 or higher will require a reboot.
    if [ $RETVAL -ge 2 ]; then
      # An error code equal to or greater than 4 means that some errors
      # could not be corrected.  This requires manual attention, so we
      # offer a chance to try to fix the problem in single-user mode:
      if [ $RETVAL -ge 4 ]; then
        echo
        echo "***********************************************************"
        echo "*** An error occurred during the root filesystem check. ***"
        echo "*** You will now be given a chance to log into the      ***"
        echo "*** system in single-user mode to fix the problem.      ***"
        echo "***                                                     ***"
        echo "*** If you are using the ext2 filesystem, running       ***"
        echo "*** 'e2fsck -v -y <partition>' might help.              ***"
        echo "***********************************************************"
        echo
        echo "Once you exit the single-user shell, the system will reboot."
        echo
        PS1="(Repair filesystem) \#"; export PS1
        sulogin
      else # With an error code of 2 or 3, reboot the machine automatically:
        echo
        echo "***********************************"
        echo "*** The filesystem was changed. ***"
        echo "*** The system will now reboot. ***"
        echo "***********************************"
        echo
      fi
      echo "Unmounting file systems."
      /sbin/umount -a -r
      /sbin/mount -n -o remount,ro /
      echo "Rebooting system."
      reboot -f
    fi
    # Remount the root filesystem in read-write mode
    echo "Remounting root device with read-write enabled."
    /sbin/mount -w -v -n -o remount /
    if [ $? -gt 0 ] ; then
      echo "FATAL:  Attempt to remount root device as read-write failed!  This is going to"
      echo "cause serious problems."
    fi
  else
    echo "Testing root filesystem status:  read-write filesystem"
    echo
    echo "ERROR: Root partition has already been mounted read-write. Cannot check!"
    echo
    echo "For filesystem checking to work properly, your system must initially mount"
    echo "the root partition as read only.  If you're booting with LILO, add a line:"
    echo
    echo "   read-only"
    echo
    echo "to the Linux section in your /etc/lilo.conf and type 'lilo' to reinstall it."
  fi # Done checking root filesystem
fi
