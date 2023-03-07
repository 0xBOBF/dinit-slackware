#!/bin/bash
#
# lvm.sh - Open any volumes created by cryptsetup.
#
# Some notes on /etc/crypttab in Slackware:
# Only LUKS formatted volumes are supported (except for swap)
# crypttab follows the following format:
# <luks_name> <device> <password> <options>
#
# <luks_name>:  This is the name of your LUKS volume.
# For example:  crypt-home
#
# <device>:  This is the device containing your LUKS volume.
# For example:  /dev/sda2
#
# <password>:  This is either the volume password in plain text, or the name of
# a key file.  Use 'none' to interactively enter password on boot.
#
# <options>:  Comma-separated list of options.  Note that there must be a
# password field for any options to be picked up (use a password of 'none' to
# get a password prompt at boot).  The following options are supported:
#
# discard -- this will cause --allow-discards to be passed to the cryptsetup
# program while opening the LUKS volume.
#
# ro -- this will cause --readonly to be passed to the cryptsetup program while
# opening the LUKS volume.
#
# swap -- this option cannot be used with other options.  The device given will
# be formatted as a new encrypted volume with a random key on boot, and used as
# swap.

# Source any environment customizations:
. /etc/dinit/system/scripts/env

if [ -f /etc/crypttab -a -x /sbin/cryptsetup -a -z "$container" ]; then
  # First, check for device-mapper support.
  if ! grep -wq device-mapper /proc/devices ; then
    # If device-mapper exists as a module, try to load it.
    # Try to load a device-mapper kernel module:
    /sbin/modprobe -q dm-mod
  fi
  # NOTE: we only support LUKS formatted volumes (except for swap)!
  cat /etc/crypttab | grep -v "^#" | grep -v "^$" | while read line; do
    eval LUKSARRAY=( $line )
    LUKS="${LUKSARRAY[0]}"
    DEV="${LUKSARRAY[1]}"
    PASS="${LUKSARRAY[2]}"
    OPTS="${LUKSARRAY[3]}"
    LUKSOPTS=""
    if echo $OPTS | grep -wq ro ; then LUKSOPTS="${LUKSOPTS} --readonly" ; fi
    if echo $OPTS | grep -wq discard ; then LUKSOPTS="${LUKSOPTS} --allow-discards" ; fi
    # Skip LUKS volumes that were already unlocked (in the initrd):
    /sbin/cryptsetup status $LUKS 2>/dev/null | head -n 1 | grep -q "is active" && continue
    if /sbin/cryptsetup isLuks $DEV 2>/dev/null ; then
      if [ -z "${LUKSOPTS}" ]; then
        echo "Unlocking LUKS encrypted volume '${LUKS}' on device '$DEV':"
      else
        echo "Unlocking LUKS encrypted volume '${LUKS}' on device '$DEV' with options '${LUKSOPTS}':"
      fi
      if [ -n "${PASS}" -a "${PASS}" != "none" ]; then
        if [ -f "${PASS}" ]; then
          # A password was given a key-file filename
          /sbin/cryptsetup ${LUKSOPTS} --key-file=${PASS} luksOpen $DEV $LUKS
        else
          # A password was provided in plain text
          echo "${PASS}" | /sbin/cryptsetup ${LUKSOPTS} luksOpen $DEV $LUKS
        fi
      else
        # No password was given, or a password of 'none' was given
        /sbin/cryptsetup ${LUKSOPTS} luksOpen $DEV $LUKS </dev/tty0 >/dev/tty0 2>&1
      fi
    elif echo $OPTS | grep -wq swap ; then
      # If any of the volumes is to be used as encrypted swap,
      # then encrypt it using a random key and run mkswap:
      echo "Creating encrypted swap volume '${LUKS}' on device '$DEV':"
      /sbin/cryptsetup --cipher=aes --key-file=/dev/urandom --key-size=256 create $LUKS $DEV
      mkswap /dev/mapper/$LUKS
    fi
  done
fi
