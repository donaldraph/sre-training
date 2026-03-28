# Day 005 Debug — Three Problems Combined Challenge

---

## The Challenge

Three things are simultaneously wrong on the system. Use the 60-second checklist to find all three. Time yourself.

**Start time:** _(fill in when you ran it)_
**End time:** _(fill in when you found all three)_

---

## Setup — Start All Three Problems

```bash
# Problem 1: CPU stress
stress-ng --cpu 2 --timeout 120 &

# Problem 2: Disk fill
dd if=/dev/zero of=/tmp/bigfile bs=1M count=200 &

# Problem 3: File descriptor leak
python3 -c "
fds = []
for i in range(900):
    fds.append(open(f'/tmp/fd_leak_{i}', 'w'))
import time; time.sleep(120)
" &
```

Three background processes now running. Clock starts.

---

## Investigation — Working Through the Checklist

### Step 1 — `uptime`

```bash
uptime
```

![uptime during challenge](../screenshots/day005-debug-uptime.png)

What I saw:
- Load average was noticeably higher than normal — the 1-minute was significantly above my baseline
- Confirmed something was consuming CPU — load climbing

---

### Step 2 — `dmesg | tail`

```bash
dmesg | tail
```

![dmesg during challenge](../screenshots/day005-debug-dmesg.png)

What I saw:
- No OOM kills yet — the disk fill and fd leak hadn't caused kernel-level problems at this point
- Clean kernel log — rules out hardware issues

---

### Step 3 — `vmstat 1 5`

```bash
vmstat 1 5
```

![vmstat during challenge](../screenshots/day005-debug-vmstat.png)

What I saw:
- `us` (user CPU) was elevated — confirms a user-space process eating CPU
- `wa` (iowait) showed some activity — the `dd` disk fill was causing I/O wait
- Two signals in one command — CPU problem and I/O problem both visible here

---

### Step 4 — `mpstat -P ALL 1 3`

```bash
mpstat -P ALL 1 3
```

![mpstat during challenge](../screenshots/day005-debug-mpstat.png)

What I saw:
- Two cores were pegged near 100% user CPU — matches `stress-ng --cpu 2`
- Other cores mostly idle — confirms it's a 2-thread process, not system-wide load
- **Problem 1 confirmed: CPU stress on 2 cores**

---

### Step 5 — `pidstat 1 3`

```bash
pidstat 1 3
```

![pidstat during challenge](../screenshots/day005-debug-pidstat.png)

What I saw:
- `stress-ng` processes showing ~100% CPU each — found the culprit by name
- `dd` process also visible with I/O activity
- **Problem 1 identified: stress-ng**

---

### Step 6 — `iostat -xz 1 3`

```bash
iostat -xz 1 3
```

![iostat during challenge](../screenshots/day005-debug-iostat.png)

What I saw:
- `sda` showing elevated `w/s` (writes per second) and increasing `%util`
- `w_await` was higher than baseline — writes were queuing
- **Problem 2 confirmed: disk being filled by dd**

Finding the specific file:
```bash
ls -lh /tmp/bigfile
# Shows the growing file
df -h /tmp
# Shows space being consumed
```

---

### Step 7 — `free -m`

```bash
free -m
```

![free during challenge](../screenshots/day005-debug-free.png)

What I saw:
- Memory looked normal — the fd leak wasn't consuming significant RAM yet
- Swap still at zero — no memory pressure from the stress test

---

### Step 8 — Finding Problem 3 (File Descriptor Leak)

The 60-second checklist doesn't directly show fd leaks — needed to dig further:

```bash
# Check which process has the most file descriptors open
for pid in $(ls /proc | grep -E '^[0-9]+$'); do
    count=$(ls /proc/$pid/fd 2>/dev/null | wc -l)
    name=$(cat /proc/$pid/comm 2>/dev/null)
    echo "$count $name ($pid)"
done | sort -rn | head -10
```

![fd leak detection](../screenshots/day005-debug-fd-leak.png)

Output showed `python3` with ~900 open file descriptors — way above normal (most processes have under 20).

Could also verify with:
```bash
ls /proc/$PYTHON_PID/fd | wc -l
# Shows ~900
ls /tmp/fd_leak_* | wc -l
# Shows ~900 files created
```

**Problem 3 confirmed: Python process with file descriptor leak**

---

## All Three Problems Found

| Problem | Tool that found it | What I saw |
|---|---|---|
| CPU stress (stress-ng) | `mpstat`, `pidstat` | 2 cores at 100% user, process named by pidstat |
| Disk fill (dd) | `iostat`, `df` | Elevated w/s and %util, growing file in /tmp |
| FD leak (python3) | `/proc/PID/fd` count | ~900 open file descriptors on one python3 process |

---

## Cleanup

```bash
pkill stress-ng
rm -f /tmp/bigfile
pkill -f "fd_leak"
rm -f /tmp/fd_leak_*
```

Verified everything was back to normal:
```bash
uptime           # load dropped back to baseline
df -h /tmp       # space freed
iostat -xz 1 1   # disk activity back to near zero
```

---

## What I Learned

- The 60-second checklist catches CPU and disk problems fast — `mpstat` and `iostat` found problems 1 and 2 within the first few commands
- File descriptor leaks don't show up on the standard checklist — you need to dig into `/proc/PID/fd` specifically
- `pidstat` is what takes you from "CPU is high" to "it's this specific process" — it's underrated
- Running three simultaneous problems made the outputs noisier and more realistic — in production things are rarely one clean problem at a time
- The timing discipline matters — noting start and end time forces you to be systematic rather than random
- After fixing, always verify with the same tools you used to diagnose — confirm the numbers went back to normal
