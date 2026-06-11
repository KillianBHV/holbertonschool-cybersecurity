# LIVE AUDIT
## SYSTEM INFORMATION
- Denomination: **`Ubuntu 22.04.5 LTS (Jammy Jellyfish)`**
- Kernel Version: **`6.1.170`**
- System running since: **`2026-05-06 09:58:03`**
- Current  user: **`student`**

## NETWORK TOPOLOGY
### OBSERVATIONS
> \- The gateway is connected to two distinct network segments through interfaces **`eth0`** and **`eth1`**
> 
> \- The **`eth1`** interface is configured with address **`10.42.202.166/16`** and uses **`10.42.0.1`** as the default gateway
> 
> \- The **`eth0`** interface is configured with an address in the APIPA range (**`169.254.172.2/22`**)

### EVIDENCE
```bash
# Interface Configuration
eth0: 169.254.172.2/22
eth1: 10.42.202.166/16
```
```bash
# Routing Table
default via 10.42.0.1 dev eth1
10.42.0.0/16 dev eth1
169.254.172.0/22 dev eth0
```
```bash
# Neighbor Discovery
10.42.0.1 dev eth1 lladdr 0a:b0:93:32:a4:d0 REACHABLE
```

### ANALYSIS
- The routing table indicates that all outbound traffic is forwarded through the gateway **`10.42.0.1`** via interface **`eth1`**
- ND information confirms Layer 2 connectivity between the gateway and the device at **`10.42.0.1`**
- The presence of an APIPA address on **`eth0`** may indicate the absence of a reachable DHCP service or an intentionally isolated network segment

## ATTACK SURFACE
### OBSERVATIONS
> \- The system is listening on multiple TCP ports across all network interfaces
>
> \- Both IPV4 (`0.0.0.0`) and IPv6 (`::`) bindings are present for TCP port 22

### EVIDENCE
```bash
# Open Ports (No UDP port found)
tcp LISTEN 0 511  0.0.0.0:3000
tcp LISTEN 0 4096 0.0.0.0:3001
tcp LISTEN 0 128  0.0.0.0:22
tcp LISTEN 0 32         *:21
tcp LISTEN 0 128     [::]:22
```

### ANALYSIS
- The system exposes multiple network-facing services accross all interfaces, increasing the external attack surface
- Key exposed services include:
  - SSH on TCP 22
  - FTP on TCP 21
  - Application Services on TCP 3000 and TCP 3001
- The presence of services bound to 0.0.0.0 and :: indicates that they are reachable from **all network interfaces**

## SECURITY CONTROLS
> - No active firewall and even installed (no SELinux/AppArmor found)
> - No logging and monitoring process found

## USER ACCOUNTS
### OBSERVATIONS
> \- There is only two user-level accounts: **`student`** and **`root`**
>
> \- The **sudo** group exists, but has not user associated with it (at this step)
>
> \- Remote password authentication is allowed, but considered as a bad practice nowadays
> 
> \- The higher privileged default user *(root)* is allowed to connect remotely

## EVIDENCE
```bash
root:x:0:0:root:/root:/bin/bash
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
sshd:x:105:65534::/run/sshd:/usr/sbin/nologin
ftp:x:106:109:ftp daemon,,,:/srv/ftp:/usr/sbin/nologin
telnetd:x:107:110::/nonexistent:/usr/sbin/nologin
student:x:1000:1000::/home/student:/bin/bash
```
```bash
root:x:0:
sudo:x:27:
users:x:100:
nogroup:x:65534:
_ssh:x:101:
crontab:x:107:
ssl-cert:x:108:
ftp:x:109:
telnetd:x:110:
student:x:1000:
```
```bash
# sshd_config sections
PermitRootLogin yes
PubkeyAuthentication yes
PasswordAuthentication yes
```

## SCHEDULED TASKS
### OBSERVATIONS
> \- HTTP request is repeatedly send as root *(with curl command)*
> 
> \- curl command executes every **minute** *(cron rule)*

### EVIDENCE
```bash
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root          78  0.0  0.1   3888  2112 ?        Ss   08:00   0:00 /usr/sbin/cron -P
root        1063  0.0  0.2   7324  4040 ?        S    12:33   0:00 /usr/sbin/CRON -P
root        1064  0.0  0.0   2892   956 ?        Ss   12:33   0:00 /bin/sh -c /usr/bin/curl http://192.168.1.200/ping
root        1065  0.0  0.4  19428  8412 ?        S    12:33   0:00 /usr/bin/curl http://192.168.1.200/ping
root        1066  0.0  0.2   7324  4040 ?        S    12:34   0:00 /usr/sbin/CRON -P
root        1067  0.0  0.0   2892  1028 ?        Ss   12:34   0:00 /bin/sh -c /usr/bin/curl http://192.168.1.200/ping
root        1068  0.0  0.4  19428  8312 ?        S    12:34   0:00 /usr/bin/curl http://192.168.1.200/ping
```
```bash
* * * * * root /usr/bin/curl http://192.168.1.200/ping
```

### RISK
- This behavior may acts as a backdoor/component, which can potentially lead to privilege escalation

## RUNNING SERVICES
- **`sshd`**, **`vsftpd`**, **`cron`**, **`ttyd`**, **`OpenVSCode server`** are confirmed

## DISCREPANCIES
- Ports 3000/3001 have no documentation 
- ttyd and OpenVSCode server running with credential arguments in process command line.
- Non-ndocumented root cron job to 192.168.1.200
- Sensitive credentials and architecture details left world-readable
