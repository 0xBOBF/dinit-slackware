#!/bin/bash
#
# clock-hw.sh - Set the system time from the hardware clock using hwclock --hctosys.

# Source any environment customizations:
. /etc/dinit/system/scripts/env

if [ -x /sbin/hwclock -a -z "$container" ]; then
  # Check for a broken motherboard RTC clock (where ioports for rtc are
  # unknown) to prevent hwclock causing a hang:
  if ! grep -q " : rtc" /proc/ioports ; then
    CLOCK_OPT="--directisa"
  fi
  if [ /etc/adjtime -nt /etc/hardwareclock ]; then
    if grep -q "^LOCAL" /etc/adjtime ; then
      echo -n "Setting system time from the hardware clock (localtime):  "
    else
      echo -n "Setting system time from the hardware clock (UTC):  "
    fi
    /sbin/hwclock $CLOCK_OPT --hctosys
  elif grep -wq "^localtime" /etc/hardwareclock 2> /dev/null ; then
    echo -n "Setting system time from the hardware clock (localtime):  "
    /sbin/hwclock $CLOCK_OPT --localtime --hctosys
  else
    echo -n "Setting system time from the hardware clock (UTC):  "
    /sbin/hwclock $CLOCK_OPT --utc --hctosys
  fi
  date
fi
