# Day 004 Debug — DNS Failure Diagnosis

---

## The Scenario

A service can't connect to an external API. Simulate the failure by breaking DNS, diagnose what's wrong using the right tools, confirm it's a DNS issue and not a network issue, then fix it.

---

## Setup — Break DNS

### Commands
```bash
sudo cp /etc/resolv.conf /etc/resolv.conf.bak
sudo bash -c 'echo "nameserver 192.0.2.1" > /etc/resolv.conf'
```

### What This Does
Replaces the working DNS server (`127.0.0.53`) with `192.0.2.1` — an IP address in a range specifically reserved for documentation and testing that is guaranteed to be unreachable on any real network. Any DNS query will now time out.

---

## Step 1 — Observe the Failure

### Command
```bash
curl -v --connect-timeout 5 https://httpbin.org/get 2>&1 | head -20
```

### Observations

![curl failure output](../screenshots/day004-curl-fail.png)

Output:
```
* Could not resolve host: httpbin.org
* Closing connection 0
curl: (6) Could not resolve host: httpbin.org
```

The error is **"Could not resolve host"** — not "connection refused" or "connection timed out". That phrasing specifically means DNS failed. The HTTP request never even started because the name never resolved to an IP.

---

## Step 2 — Diagnose with dig

### Command
```bash
dig httpbin.org
```

### Observations

![dig failure output](../screenshots/day004-dig-fail.png)

Output:
```
;; communications error to 192.0.2.1#53: timed out
;; communications error to 192.0.2.1#53: timed out
;; communications error to 192.0.2.1#53: timed out

; <<>> DiG <<>> httpbin.org
;; connection timed out; no servers could be reached
```

`dig` confirms it — the DNS server at `192.0.2.1` is not responding. Three attempts, all timed out. This tells me the DNS server is the problem, not the domain itself.

---

## Step 3 — Test if IP Connectivity Still Works

### Command
```bash
curl -v http://1.1.1.1
```

### Observations

![curl IP test output](../screenshots/day004-curl-ip.png)

Output:
```
* Connected to 1.1.1.1 port 80
< HTTP/1.1 301 Moved Permanently
```

Got a response — the network itself is fine. Packets are flowing. The problem is purely DNS. `1.1.1.1` is Cloudflare's DNS server but I hit it directly via IP, bypassing DNS entirely.

This is the key diagnostic step — it separates "DNS is broken" from "the whole network is broken". If this also failed, the problem would be routing or connectivity, not DNS.

---

## Step 4 — Confirm with nslookup

### Command
```bash
nslookup httpbin.org
```

### Observations
```
;; connection timed out; no servers could be reached
```

Same result from a different tool. Both `dig` and `nslookup` confirm the DNS server is unreachable.

---

## Step 5 — Fix It

### Command
```bash
sudo cp /etc/resolv.conf.bak /etc/resolv.conf
```

### Observations
Restored the backup. DNS immediately started working again:
```bash
dig httpbin.org
# Returns: httpbin.org. 10 IN A 54.91.34.x
```

And curl works again:
```bash
curl -v --connect-timeout 5 https://httpbin.org/get 2>&1 | head -5
# Returns: HTTP/2 200
```

---

## The Diagnostic Flow

The order I used matters:

1. **See the error** — "Could not resolve host" immediately points to DNS
2. **Test DNS directly** — `dig domain` to confirm the resolver is broken
3. **Test IP connectivity** — `curl http://IP` to rule out network issues
4. **Check resolv.conf** — `cat /etc/resolv.conf` to see which DNS server is configured
5. **Fix and verify** — restore the config, test again

In a real incident this is the same flow. "Service can't reach external API" almost always comes down to: DNS broken, wrong DNS server, firewall blocking port 53, or the domain itself doesn't resolve. Testing IP directly separates these cases quickly.

---

## What I Learned

- "Could not resolve host" = DNS problem, not network problem
- `dig domain` is the fastest way to test DNS directly
- `curl http://IP` bypasses DNS entirely — if this works and the hostname doesn't, you've isolated the problem to DNS
- `cat /etc/resolv.conf` shows which DNS server is configured — first thing to check when DNS is broken
- `192.0.2.0/24` is a reserved "documentation" range that's guaranteed unreachable — perfect for simulating broken DNS
- Always back up config files before breaking them (`cp /etc/resolv.conf /etc/resolv.conf.bak`)
- The fix is often just restoring a config — understanding why it broke in the first place is the harder part
