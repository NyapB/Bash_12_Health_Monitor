#!/bin/bash

disk_pct=$(df / | awk 'NR == 2 { gsub("%", "", $5); print $5}')
mem_pct=$(free | awk '/^Mem: /{print "%.0f", $3 /$2* 10}')
echo "Disk: ${disk_pct}% Memory: ${mem_pct}%"