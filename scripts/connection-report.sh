#!/bin/bash
set -euo pipefail

echo "=== CONNECTION REPORT ==="
echo ""
echo "--- Listening Services ---"
ss -tlnp | awk 'NR>1 {print $4, $7}' | column -t
echo ""
echo "--- Established Connections by Remote IP ---"
ss -tn state established | awk 'NR>1 {split($5,a,":"); print a[1]}' | sort | uniq -c | sort -rn | head -10
echo ""
echo "--- Connection States ---"
ss -s
echo ""
echo "--- DNS Resolution Test ---"
for domain in google.com github.com amazonaws.com; do
    RESULT=$(dig +short $domain A | head -1)
    echo "$domain -> ${RESULT:-FAILED}"
done
echo ""
echo "--- Route to Internet ---"
ip route get 8.8.8.8 2>/dev/null || echo "No route to 8.8.8.8"
