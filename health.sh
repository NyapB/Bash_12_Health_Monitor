#!/bin/bash

set -euo pipefail
#limits with defaults
DISK_LIMIT=${DISK_LIMIT:-85}
MEM_LIMIT=${MEM_LIMIT:-80}

quiet="false"
if [[ "${1:-}" == "--quiet" ]]; then
    quiet=true
fi

exit_status=0

hostname=$(hostname)
timestamp=$(date '+%Y-%M-%d %H:%')
log_dir="$HOME/logs"
log_file="$log_dir/health.log"

mkdir -p "$log_dir"

disk_pct=$(df / | awk 'NR == 2 { gsub("%", "", $5); print $5}')
mem_pct=$(free | awk '/^Mem: /{print "%.0f", ($3 / $2)* 100}')
load=$(awk '{print $1}' /proc/loadavg)
cores=$(nproc)

if [[ "$quiet" == "false" ]]; then
    echo "System health: $hostname ($timestamp)"
fi


#DISK CHECK
if ((disk_pct > DISK_LIMIT)); then
    exit_status=1

    if [[ "$quiet" == "false" ]]; then
        echo "Disk $disk_pct% warn (Limit ${DISK_LIMIT}%)"
    fi
    echo "[$timestamp] [WARN] Disk is ${disk_pct}% (limit ${DISK_LIMIT}%)" >> "$log_file"
else
    if [[ "$quiet" == "false" ]]; then
        echo "disk ${disk_pct}% OK"
    fi
    echo "[$timestamp] [INFO] Disk is ${disk_pct}% OK" >> "$log_file"   
fi
#memory check
if [[ "$mem_pct" > "$MEM_LIMIT" ]]; then
    exit_status=1

    if [[ "$quiet" == "false" ]]; then
        echo "[$timestamp] [WARN] Mwemory is ${mem_pct}% (limit ${MEM_LIMIT}%)" >> "$log_file"
    fi

else
    if [[ "$quiet" == "false" ]]; then
        echo "Memory ${mem_pct}% is OK"
    fi
    echo "[$timestamp] [INFO] Memory is ${mem_pct}% OK" >> "$log_file"
fi

#load check
if awk -v l="$load" -v n="$cores" 'BEGIN {exit !(l / n > 1.0)}'; then
    exit_status=1
    if [[ "$quiet" == "false" ]]; then
        echo "Load $load on $cores cores WARN (limit 1.0 per core)"
    fi
    echo "[$timestamp] [WARN] Load $load on $cores cores is high" >> "$log_file"
else
    if [[ "$quiet" == "false" ]]; then
        echo "Load $load on $cores cores OK"
    fi
    echo "[$timestamp] [INFO] Load $load on $cores cores OK" >> "$log_file"
fi
# echo "Disk: $disk_pct%"
# echo "memory: $mem_pct%"
# echo "Load: $load on $cores cores"
exit "$exit_status"
