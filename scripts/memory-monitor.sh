#!/bin/bash
set -euo pipefail
# Monitors a PID's memory every 2 seconds, writes CSV
PID=${1:?"Usage: $0 <PID>"}
OUTPUT="/workspace/sre-training/notes/mem-monitor-${PID}.csv"
echo "timestamp,pid,rss_kb,vsz_kb,pct_mem" > "$OUTPUT"

while kill -0 "$PID" 2>/dev/null; do
    TIMESTAMP=$(date +%s)
    DATA=$(ps -p "$PID" -o rss=,vsz=,%mem= 2>/dev/null || echo "0 0 0")
    RSS=$(echo $DATA | awk '{print $1}')
    VSZ=$(echo $DATA | awk '{print $2}')
    PCT=$(echo $DATA | awk '{print $3}')
    echo "$TIMESTAMP,$PID,$RSS,$VSZ,$PCT" >> "$OUTPUT"
    sleep 2
done
echo "Process $PID ended. Data in $OUTPUT"
