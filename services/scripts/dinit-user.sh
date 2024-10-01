#!/bin/bash
#
# dinit-user.sh
# 
# This script triggers user services to start or stop using dinit/dinitctl. 
# It is intended to be called using pam_exec.so during a login through PAM.
#
# Only first login and last logout of a user triggers user service changes.
#
# This script also handles creation of the XDG_RUNTIME_DIR so it is available
# for services and dinit to use. Destruction of the XDG_RUNTIME_DIR will still
# be handled by elogind on Slackware.
#
# Written by Bob Funk, 2021 - 2023

# Only run when called from PAM, and uids >= 1000 (i.e. regular users only):
if [ -n "$PAM_USER" ] && [ -n "$PAM_TYPE" ]; then 
  uid="$(id -u "$PAM_USER" )"
  [ "$uid" -lt "1000" ] && exit 0
  SESSION_CNT="$(loginctl show-user "$PAM_USER" | sed -n 's/^Sessions=//p' | wc -w)" 
  case "$PAM_TYPE" in
    "open_session")
      [ "$SESSION_CNT" -ge "1" ] && exit 0
      # Create the XDG_RUNTIME_DIR so its available to our scripts.
      # Note: This must be a tmpfs mountpoint, with proper permissions, 
      #       or it will be clobbered and made anew by elogind!
      mkdir -m700 "/run/user/$uid"
      mount -t tmpfs -o uid=$uid,gid=100,mode=700 tmpfs "/run/user/$uid"

      /usr/bin/pkexec --user "$PAM_USER" "$0" "start" &
      ;;
    "close_session")
      [ "$SESSION_CNT" != "1" ] && exit 0
      /usr/bin/pkexec --user "$PAM_USER" "$0" "stop" &
      ;;
    *)
      exit 0
      ;;
  esac
  # A slight pause to allow the forked user version of this
  # script to set up inotifywaits on XDG_RUNTIME_DIR:
  sleep 1
fi

# The following bit runs as the user (through pkexec):
if [ -n "$PKEXEC_UID" ] && [ -n "$1" ]; then
  # Create the XDG_RUNTIME_DIR so its available to our scripts.
  # Note: This must be a tmpfs mountpoint, with proper permissions, 
  #       or it will be clobbered and made anew by elogind!
  export XDG_RUNTIME_DIR="/run/user/$(id -u $USER)"
  case "$1" in
    "start")
      # Start a user dinit instance, and put the dinitctl socket 
      # in the $XDG_RUNTIME_DIR so the user can use dinitctl to 
      # control their services. Also use a system-wide user service
      # location at /etc/dinit.d/user so that all users can access 
      # some common services. A boot service in $HOME/.config will
      # still override the system-wide services:
      /sbin/dinit -q \
        -p "$XDG_RUNTIME_DIR/dinitctl" \
        -d "$HOME/.config/dinit.d" \
        -d "/etc/dinit.d/user" &
      ;;
    "stop")
      # Issue the shutdown command as the user, which will stop all
      # running services for the user:
      /sbin/dinitctl shutdown
      ;;
    *)
      # Should never get here, just exit.
      exit 0
      ;;
  esac
fi
