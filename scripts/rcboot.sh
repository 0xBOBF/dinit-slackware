#!/bin/bash
export PATH=/usr/bin:/usr/sbin:/bin:/sbin

set -e

if [ "$1" != "stop" ]; then
  # Make sure that /var/run is a symlink pointing to /run:
  if [ -d /run -a ! -L /var/run ]; then
    (cd /var ; rm -rf run ; ln -sf /run run)
  fi

  # Make /var/run/dbus for the dbus daemon's pid files:
  mkdir -p -m og-w /var/run/dbus

  # Clean up some temporary files:
  rm -f /etc/nologin /etc/dhcpc/*.pid /etc/forcefsck /etc/fastboot \
    /var/state/saslauthd/saslauthd.pid /tmp/.Xauth*
  
  rm -rf /tmp/{kde-[a-zA-Z]*,ksocket-[a-zA-Z]*,hsperfdata_[a-zA-Z]*,plugtmp*}

  if [ -d /var/lib/pkgtools/setup/tmp ]; then
    ( cd /var/lib/pkgtools/setup/tmp && rm -rf * )
  elif [ -d /var/log/setup/tmp ]; then
    ( cd /var/log/setup/tmp && rm -rf * )
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
  # if the firstline of the file begins with the word 'Linux'.
  # You are free to modify the rest of the file as you see fit.
  if [ -x /bin/sed ]; then
    /bin/sed -i "{1s/^Linux.*/$(/bin/uname -sr)\./}" /etc/motd
  fi

  # Configure random number generator
  if [ -e /var/state/random-seed ]; then
    cat /var/state/random-seed > /dev/urandom;
  fi
  
  # Update all the shared library links:
  if [ -x /sbin/ldconfig ]; then
    /sbin/ldconfig
  fi
  
  # Set screen blanking and power management defaults:
  /bin/setterm -blank 15 -powerdown 60
  
  # Set console font:
  /usr/bin/setfont -v ter-120b


  # Set the hostname:
  if [ -r /etc/HOSTNAME ]; then
    hostname $(cat /etc/HOSTNAME)
  else
    # fall back on this old defaut:
    echo "darkstar.example.net" > /etc/HOSTNAME
    hostname $(cat /etc/HOSTNAME)
  fi

  # Set the permissions on /var/log/dmesg according to whether the kernel
  # permits non-root users to access kernel dmesg information:
  if [ -r /proc/sys/kernel/dmesg_restrict ]; then
    if [ $(cat /proc/sys/kernel/dmesg_restrict) = 1 ]; then
      touch /var/log/dmesg
      chmod 640 /var/log/dmesg
    fi
  else
    touch /var/log/dmesg
    chmod 644 /var/log/dmesg
  fi
  # Save the contents of 'dmesg':
  dmesg -s 65536 > /var/log/dmesg

  # Update the X font indexes:
  if [ -x /usr/bin/fc-cache ]; then
    /usr/bin/fc-cache -f
  fi

  # Remove stale locks and junk files:
  rm -rf /var/lock/* /var/spool/uucp/LCK..* /tmp/.X*lock /tmp/.X11-unix/*

  # Remove stale hunt sockets so the game can start:
  if [ -r /tmp/hunt -o -r /tmp/hunt.stats ]; then
    rm -f /tmp/hunt*
  fi

  # Ensure basic filesystem permissions sanity:
  chmod 755 / 
  chmod 1777 /tmp /var/tmp

  # Update any existing icon cache files:
  if find /usr/share/icons -maxdepth 2 2> /dev/null | grep -q icon-theme.cache ; then
    for theme_dir in /usr/share/icons/* ; do
      if [ -r ${theme_dir}/icon-theme.cache ]; then
        /usr/bin/gtk-update-icon-cache -t -f ${theme_dir}
      fi
    done
    # This would be a large file and probable shouldn't be there.
    if [ -r /usr/share/icons/icon-theme.cache ]; then
      rm -f /usr/share/icons/icon-theme.cache
    fi
  fi

  # These GTK+/pango files need to be kept up to date for
  # proper input method, pixbuf loaders, and font support.
  if [ -x /usr/bin/update-gtk-immodules ]; then
    /usr/bin/update-gtk-immodules
  fi
  if [ -x /usr/bin/update-gdk-pixbuf-loaders ]; then
    HOME=/root /usr/bin/update-gdk-pixbuf-loaders
  fi
  if [ -x /usr/bin/update-pango-querymodules ]; then
    /usr/bin/update-pango-querymodules
  fi
  if [ -x /use/bin/glib-compile-schemas ]; then
    /usr/bin/glib-compile-schemas /usr/share/glib-2.0/schemas
  fi
  
  # Update mime database:
  if [ -x /usr/bin/update-mime-database -a -d /usr/share/mime ]; then
    /usr/bin/update-mime-database /usr/share/mime
  fi
  
else

  # The system is being shut down
  
  # echo "Saving random number seed..."
  POOLSIZE="$(cat /proc/sys/kernel/random/poolsize)"
  dd if=/dev/urandom of=/var/state/random-seed bs="$POOLSIZE" count=1 2> /dev/null

fi;

