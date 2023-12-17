#!/bin/bash
export PATH=/usr/bin:/usr/sbin:/bin:/sbin

set -e

if [ "$1" != "stop" ]; then
  # Set rpc LOCKD ports if needed (from rc.rpc):
  if [ -r /etc/default/rpc ]; then
    . /etc/default/rpc
    if [ -n "$LOCKD_TCP_PORT" ]; then
      /sbin/sysctl -w "fs.nfs.nlm_tcpport=$LOCKD_TCP_PORT"
    fi
    if [ -n "$LOCKD_UDP_PORT" ]; then
      /sbin/sysctl -w "fs.nfs.nlm_udpport=$LOCKD_UDP_PORT"
    fi
  fi 
fi;
