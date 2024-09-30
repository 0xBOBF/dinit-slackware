#!/bin/bash

for ((i=0;i<$(/usr/bin/cpufreq-info | /bin/grep -c "analyzing CPU");i++)); do
  /usr/bin/cpufreq-set -c $i -g "$1"
done
