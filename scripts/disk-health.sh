#!/bin/bash
set -euo pipefail

echo "=== DISK HEALTH REPORT ==="
echo "Date: $(date)"
echo ""

echo "--- Filesystem Usage ---"
df -hT | grep -vE "tmpfs|devtmpfs|squashfs"
echo ""

echo "--- Inode Usage ---"
df -i | grep -vE "tmpfs|devtmpfs|squashfs"
echo ""

echo "--- Top 10 Largest Directories in / ---"
du -h --max-depth=2 / 2>/dev/null | sort -rh | head -10
echo ""

echo "--- Files Modified in Last Hour ---"
find /var/log -mmin -60 -type f 2>/dev/null | head -10
echo ""

echo "--- Current I/O Stats ---"
iostat -x 1 1 | tail -n +4
echo ""

# Alert if any filesystem > 80%
echo "--- ALERTS ---"
df -h | awk 'NR>1 && +$5 > 80 {print "WARNING: " $6 " is " $5 " full"}'
