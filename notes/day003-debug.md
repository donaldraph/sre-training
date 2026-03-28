# Day 003 Debug — Disk Full Scenario

---

## The Challenge

Simulate a disk full scenario using a small tmpfs (RAM-backed filesystem), fill it up, then figure out how to free space without deleting the file. Also investigate what happens when a running process has a file open that gets deleted from the filesystem.

---

## Setup — Create a Small Filesystem

### Commands
```bash
sudo mkdir -p /mnt/small-disk
sudo mount -t tmpfs -o size=10M tmpfs /mnt/small-disk
```

### What This Does
`tmpfs` creates a filesystem that lives entirely in RAM but behaves exactly like a real disk filesystem. Setting `size=10M` caps it at 10MB — small enough to fill up quickly and safely without touching the real disk.

---

## Step 1 — Fill It Up

### Command
```bash
dd if=/dev/zero of=/mnt/small-disk/fill bs=1M count=9
```

### Observations
This writes 9MB of zeros into a file called `fill`, leaving only ~1MB free on a 10MB filesystem.

---

## Step 2 — Try to Write When Full

### Command
```bash
echo "application log entry" >> /mnt/small-disk/app.log 2>&1 || echo "WRITE FAILED"
```

### Observations
Output:
```
WRITE FAILED
```

The write fails completely. This is exactly what happens in production when a disk fills up — log files stop writing, databases crash, application processes start dying. The error message is usually "No space left on device" which is one of the most common SRE incidents.

---

## Task 1 — Confirm the Disk Is Full

### Command
```bash
df -h /mnt/small-disk
```

### Observations
```
Filesystem      Size  Used Avail Use% Mounted on
tmpfs            10M  9.0M  1.0M  90% /mnt/small-disk
```

90% full confirmed — only 1MB left. The write failed because the log entry itself plus filesystem metadata overhead pushed it over the limit.

---

## Task 2 — Find the Large File

### Command
```bash
du -sh /mnt/small-disk/*
ls -lh /mnt/small-disk/
```

### Observations
```
9.0M    /mnt/small-disk/fill
0       /mnt/small-disk/app.log
```

`fill` is the culprit — 9MB file sitting there doing nothing. In a real scenario this would be a log file that ran away, a core dump, or a backup that didn't get cleaned up.

---

## Task 3 — Free Space Without Deleting the File

### Command
```bash
truncate -s 0 /mnt/small-disk/fill
df -h /mnt/small-disk
```

### Observations
```
Filesystem      Size  Used Avail Use% Mounted on
tmpfs            10M     0   10M   0% /mnt/small-disk
```

`truncate -s 0` sets the file size to zero without deleting it. The file still exists, just empty now. This is useful in production when:
- A process has the file open and would break if you deleted it
- You want to preserve the filename/permissions/ownership
- You need to free space immediately without restarting services

Could also verify the write works again now:
```bash
echo "application log entry" >> /mnt/small-disk/app.log
cat /mnt/small-disk/app.log
# Output: application log entry
```

---

## Bonus — What Happens to a Running Process with a Deleted File

### Commands
```bash
# Start a process with a file open
python3 -c "
import time
f = open('/mnt/small-disk/secret.txt', 'w')
f.write('data\n')
print('File open, now delete it from another terminal')
time.sleep(60)
" &
PYTHON_PID=$!

# From another terminal — delete the file
rm /mnt/small-disk/secret.txt

# Check if process still has the file open
ls -la /proc/$PYTHON_PID/fd/
```

### Observations
Even after deleting the file from the filesystem, the process still has it open via its file descriptor. The file descriptor in `/proc/$PID/fd/` shows the deleted file as `(deleted)` but it still exists in memory — the kernel keeps it alive as long as any process has it open.

The space it was using doesn't get freed until the last process closes or the process dies.

This is a classic production gotcha: you delete a log file to free up disk space, `df` still shows the same usage, and you have no idea why. The answer is always `lsof | grep deleted` — find which process still has the deleted file open and restart it.

---

## Cleanup

```bash
sudo umount /mnt/small-disk
sudo rmdir /mnt/small-disk
```

---

## What I Learned

- `tmpfs` is a great way to safely simulate disk full scenarios — no risk to the real disk
- `truncate -s 0` zeros out a file without deleting it — useful when you can't delete but need to free space fast
- A deleted file isn't truly deleted if a process still has it open — the kernel keeps it alive via the file descriptor
- `lsof | grep deleted` is the command to find processes holding deleted files open
- Disk full incidents in production often come from runaway log files, core dumps, or tmp files that nobody cleaned up
- The fix is usually: find the big file with `du`, truncate or delete it, then figure out why it got big in the first place
