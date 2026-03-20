#!/bin/bash
python3 -c "
import os, time
pid = os.fork()
if pid > 0:
    time.sleep(300)  # Parent sleeps, never waits for child
else:
    exit(0)  # Child exits immediately, becomes zombie
" &
echo "Parent PID: $!"
