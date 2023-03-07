#!/bin/bash
#
# cleanup.sh - Clean up temporary files and symlinks

# Source any environment customizations:
. /etc/dinit/system/scripts/env

# Make sure that /var/run is a symbolic link pointing to /run:
if [ -d /run -a ! -L /var/run ]; then
  (cd /var ; rm -rf run ; ln -sf /run run)
fi

# Clean up some temporary files:
rm -f /etc/nologin /etc/dhcpc/*.pid /etc/forcefsck /etc/fastboot \
  /var/state/saslauthd/saslauthd.pid /tmp/.Xauth* 1> /dev/null 2> /dev/null
rm -rf /tmp/{kde-[a-zA-Z]*,ksocket-[a-zA-Z]*,hsperfdata_[a-zA-Z]*,plugtmp*}
if [ -d /var/lib/pkgtools/setup/tmp ]; then
  ( cd /var/lib/pkgtools/setup/tmp && rm -rf * )
elif [ -d /var/log/setup/tmp ]; then
  ( cd /var/log/setup/tmp && rm -rf * )
fi

# Clear /var/lock/subsys:
if [ -d /var/lock/subsys ]; then
  rm -f /var/lock/subsys/*
fi

# Create /tmp/{.ICE-unix,.X11-unix} if they are not present:
if [ ! -e /tmp/.ICE-unix ]; then
  mkdir -p /tmp/.ICE-unix
  chmod 1777 /tmp/.ICE-unix
fi
if [ ! -e /tmp/.X11-unix ]; then
  mkdir -p /tmp/.X11-unix
  chmod 1777 /tmp/.X11-unix
fi

# Create a fresh utmp file:
touch /var/run/utmp
chown root:utmp /var/run/utmp
chmod 664 /var/run/utmp

# In case pam_faillock(8) is being used, create the tally directory:
mkdir -p /var/run/faillock

# Update the current kernel level in the /etc/motd (Message Of The Day) file,
# if the first line of that file begins with the word 'Linux'.
# You are free to modify the rest of the file as you see fit.
if [ -x /bin/sed ]; then
  /bin/sed -i "{1s/^Linux.*/$(/bin/uname -sr)\./}" /etc/motd
fi
