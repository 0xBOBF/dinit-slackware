#!/bin/bash

set -e

if [ "$1" = start ]; then
  
  PATH=/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin
  
  # Default values:
  TICK=10000
  FREQ=0

  # If there's a /etc/default/adjtimex config file, source it to 
  # override the default TICK and FREQ:
  if [ -r /etc/default/adjtimex ]; then
    . /etc/default/adjtimex
  fi

  if /sbin/adjtimex --tick $TICK --frequency $FREQ; then
    echo "Setting the system clock rate: /sbin/adjtimex --tick $TICK --frequency $FREQ"
  else
    echo "Failed to set system clock with adjtimex, possibly invalid parameters? (TICK=$TICK FREQ=$FREQ)"
  fi

  if [ -x /sbin/hwclock ]; then
    # Check for a broken motherboard RTC clock (where ioports for rtc are
    # unknown) to prevent hwclock causing a hang:
    if ! grep -q " : rtc" /proc/ioports ; then
      CLOCK_OPT="--directisa"
    fi
    if [ /etc/adjtime -nt /etc/hardwareclock ]; then
      if grep -q "^LOCAL" /etc/adjtime ; then
        echo -n "Setting system time from the hardware clock (localtime): "
      else
        echo -n "Setting system time from the hardware clock (UTC): "
      fi
      /sbin/hwclock $CLOCK_OPT --hctosys
    elif grep -wq "^localtime" /etc/hardwareclock ; then
      echo -n "Setting system time from the hardware clock (localtime): "
      /sbin/hwclock $CLOCK_OPT --localtime --hctosys
    else
      echo -n "Setting system time from the hardware clock (UTC): "
      /sbin/hwclock $CLOCK_OPT --utc --hctosys
    fi
    date
  fi
elif [ "$1" = "stop" ]; then
  # Shutdown:
  
  # Save the system time to the hardware clock using hwclock --systohc.
  # This will also create or update the timestamps in /etc/adjtime.
  if [ -x /sbin/hwclock ]; then
    # Check for a broken motherboard RTC clock (where ioports for rtc are
    # unknown) to prevent hwclock causing a hang:
    if ! grep -q " : rtc" /proc/ioports ; then
      CLOCK_OPT="--directisa"
    fi
    if [ /etc/adjtime -nt /etc/hardwareclock ]; then
      if grep -q "^LOCAL" /etc/adjtime ; then
        echo "Saving system time to the hardware clock (localtime)."
      else
        echo "Saving system time to the hardware clock (UTC)."
      fi
      /sbin/hwclock $CLOCK_OPT --systohc
    elif grep -q "^UTC" /etc/hardwareclock 2> /dev/null ; then
      echo "Saving system time to the hardware clock (UTC)."
      if [ ! -r /etc/adjtime ]; then
        echo "Creating system time correction file /etc/adjtime."
      fi
      /sbin/hwclock $CLOCK_OPT --utc --systohc
    else
      echo "Saving system time to the hardware clock (localtime)."
      if [ ! -r /etc/adjtime ]; then
        echo "Creating system time correction file /etc/adjtime."
      fi
      /sbin/hwclock $CLOCK_OPT --localtime --systohc
    fi
  fi
fi
