#!/bin/bash

set -euo pipefail
#limits with defaults
DISK_LIMIT=${DISK_LIMIT:-85}
MEM_LIMIT=${MEM_LIMIT:-80}

hostname=$(hostname)
timestamp=$(date '+%Y-%M-%d %H:%')

disk_pct=$(df / | awk 'NR == 2 { gsub("%", "", $5); print $5}')
mem_pct=$(free | awk '/^Mem: /{print "%.0f", ($3 / $2)* 100}')
load=$(awk '{print $1}' /proc/loadavg)
cores=$(nproc)

echo "System health $hostname ($timestamp)"

#DISK CHECK
if ((disk_pct > DISK_LIMIT)); then
    echo "Disk $disk_pct% warn (Limit ${DISK_LIMIT}%)"
else
    echo "disk ${disk_pct}% OK"
fi
#memry check
if [[ "$mem_pct" > "$MEM_LIMIT" ]]; then
    echo "Memory $mem_pct% warn (Limit ${MEM_LIMIT}%)"
else
    echo "Memory ${mem_pct}% is OK"
fi

#load check
if awk -v l="$load" -v n="$cores" 'BEGIN {exit !(l / n > 1.0)}'; then
    echo "load $load on core $cores WARN (Limit 1.0 per core)"
else
    echo "load $load on core $cores is OK"
fi
# echo "Disk: $disk_pct%"
# echo "memory: $mem_pct%"
# echo "Load: $load on $cores cores"
