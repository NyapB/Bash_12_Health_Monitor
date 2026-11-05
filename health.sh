#!/bin/bash

set -euo pipefail

hostname=$(hostname)
timestamp=$(date '+%Y-%M-%d %H:%')

disk_pct=$(df / | awk 'NR == 2 { gsub("%", "", $5); print $5}')
mem_pct=$(free | awk '/^Mem: /{print "%.0f", $3 /$2* 10}')
load=$(awk '{print $1}' /proc/loadavg)
cores=$(nproc)

echo "System health $hostname ($timestamp)"
echo "Disk: $disk_pct%"
echo "memory: $mem_pct%"
echo "Load: $load on $cores cores"
