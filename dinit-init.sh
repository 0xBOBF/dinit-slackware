#!/bin/bash
#
# dinit-init.sh
#
# This is a convenience script to switch a Slackware system between booting 
# with dinit and sysvinit. When run with the option "enable", this script
# will create symlinks for 'reboot', 'poweroff', and 'shutdown' so dinit
# can shutdown properly. When run with 'disable', these links are deleted. 

set -e

OPTION="$(echo "$1" | tr [A-Z] [a-z])"
DINIT_BOOTDIR="/etc/dinit.d/system"

case "$OPTION" in
  "enable")
      if [ ! -e "/sbin/dinit-shutdown" ]; then
        echo "Dinit doesn't appear to be installed, aborting."
      fi
      if [ "$(readlink /sbin/shutdown)" = "./dinit-shutdown" ]; then
        echo "Dinit is already enabled, aborting."
        exit
      fi
      if [ -n "$(find /var/lib/pkgtools/packages -name "sysvinit-*" | grep -vE "sysvinit-scripts|sysvinit-functions")" ]; then
        echo "The sysvinit package appears to be installed."
        echo "You must remove the sysvinit package before running this script."
        exit
      fi
      cd /sbin
      ln -sfv ./dinit-shutdown ./shutdown
      ln -sfv ./dinit-shutdown ./reboot
      ln -sfv ./dinit-shutdown ./poweroff
    ;;
  "disable")
    if ! [ "$(readlink /sbin/shutdown)" = "./dinit-shutdown" ]; then
      echo "Dinit is not enabled, aborting."
      exit
    fi
    cd /sbin
    rm -fv shutdown reboot poweroff
    echo "You will need to re-install the sysvinit package, then run:"
    echo "/sbin/dinit-shutdown --system"
    ;;
  *)
    echo "Usage: $0 [enable|disable]"
    echo "Please select whether to enable or disable dinit as system init."
    exit 1
    ;;
esac

