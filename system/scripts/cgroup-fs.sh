#!/bin/bash
#
# cgroup-fs.sh - Mount Control Groups filesystem interface
#

# Source any environment customizations:
. /etc/dinit/system/scripts/env

if [ -z "$container" ]; then
  if grep -wq cgroup /proc/filesystems ; then
    if [ -d /sys/fs/cgroup ]; then
      # See linux-*/Documentation/cgroups/cgroups.txt (section 1.6)
      # Check if we have some tools to autodetect the available cgroup controllers
      if [ -x /bin/cut -a -x /bin/tail ]; then
        # Mount a tmpfs as the cgroup filesystem root
        mount -t tmpfs -o mode=0755,size=8M cgroup_root /sys/fs/cgroup
        # Autodetect available controllers and mount them in subfolders
        controllers="$(/bin/cut -f 1 /proc/cgroups | /bin/tail -n +2)"
        for i in $controllers; do
          mkdir /sys/fs/cgroup/$i
          mount -t cgroup -o $i $i /sys/fs/cgroup/$i
        done
        unset i controllers
      else
        # We can't use autodetection so fall back mounting them all together
        mount -t cgroup cgroup /sys/fs/cgroup
      fi
    else
      mkdir -p /dev/cgroup
      mount -t cgroup cgroup /dev/cgroup
    fi
  fi
fi
