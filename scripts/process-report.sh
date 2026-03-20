#!/bin/bash
set -euo pipefail

echo "=== SYSTEM PROCESS REPORT ==="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo ""
echo "--- Top 5 CPU consumers ---"
ps aux --sort=-%cpu | head -6
echo ""
echo "--- Top 5 Memory consumers ---"
ps aux --sort=-%mem | head -6
echo ""
echo "--- Zombie processes ---"
ZOMBIES=$(ps aux | awk '$8 ~ /Z/ {print}')
if [ -z "$ZOMBIES" ]; then
    echo "None found"
else
    echo "$ZOMBIES"
fi
echo ""
echo "--- Open file descriptor count per process (top 5) ---"
for pid in $(ls /proc/ | grep -E '^[0-9]+$' | head -50); do
    count=$(ls /proc/$pid/fd 2>/dev/null | wc -l)
    name=$(cat /proc/$pid/comm 2>/dev/null || echo "unknown")
    echo "$count $name ($pid)"
done | sort -rn | head -5
