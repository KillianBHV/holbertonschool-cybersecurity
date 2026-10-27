# The Privilege Abuse Map

## 1. Initial Token Privileges

*   **SeDebugPrivilege (Used):** This privilege allows its holder to inspect and modify the memory of any process running on the machine, including kernel processes or highly privileged accounts like `lsass.exe`. We actively exploited it to bypass standard access controls by reading the memory of third-party processes and extracting sensitive data structures (SAM and SYSTEM hives temporarily stored or authentication process secrets) necessary for our lateral movement.
*   **SeImpersonatePrivilege (Used):** Designed to allow a service account to create a thread within a client's security context, this privilege can be weaponized if a highly privileged process (such as `SYSTEM`) interacts with a component controlled by our service. We used it to impersonate the token of the Windows Print Spooler service (*PrintSpoofer* / *Print Spooler*), triggering an instantaneous privilege escalation and obtaining an `NT AUTHORITY\SYSTEM` security token.
*   **SeBackupPrivilege (Unused):** This privilege bypasses all file ACLs to read any element on the disk for backup purposes. While extremely powerful for exfiltrating the SAM database and the SYSTEM hive for offline hash cracking, we did not need to actively enable it for this phase, as bypassing via impersonation and direct memory access proved faster and more stable for our immediate objective.
*   **SeChangeNotifyPrivilege (Unused):** This right allows receiving file and directory change notifications and, more importantly, traversing folders even if the user does not explicitly have read permissions on the parent folder. This is a standard privilege granted by default to almost all Windows users for normal OS operation. It offers no direct path to privilege escalation and was therefore not exploited.
*   **SeIncreaseWorkingSetPrivilege (Unused):** This privilege allows a process to increase its physical working memory size. Used by resource-intensive applications to improve performance, it offers no attack vector or security bypass. It remained unused as it provides no value in a privilege escalation scenario.

## 2. Critical Escalation Paths

### A) Abuse of SeImpersonatePrivilege via PrintSpoofer
Exploiting `SeImpersonatePrivilege` via a Named Pipe tied to the print spooler allowed a full compromise of the machine up to the `SYSTEM` level. 
*   **The Simplistic Remediation Trap:** Removing `SeImpersonatePrivilege` from `svc-web`. This account likely runs a web server (IIS or a third-party application) that strictly requires this privilege to authenticate web users and execute requests on their behalf. Removing this right would immediately paralyze the application.
*   **Realistic Production Fix:** The vulnerability does not lie within the privilege itself, but in the fact that a service running as `SYSTEM` (the spooler) accepts connections to an arbitrary named pipe controlled by a less-privileged user. The remediation consists of **purely and simply disabling the Print Spooler service** on this server if it has no printing function (which is the case for 99% of web servers). If printing is required, named pipe creation permissions must be hardened via local policies, or the web process must be isolated within a dedicated application container with inter-process communication (RPC) restrictions.

### B) Global Memory Access via SeDebugPrivilege
The `SeDebugPrivilege` privilege allowed violating the memory space of other processes to gather secrets and map permissions.
*   **The Simplistic Remediation Trap:** Removing the privilege globally. Certain monitoring agents, critical backup tools, or deeply integrated web server APM tools might require it for low-level diagnostic tasks in production.
*   **Realistic Production Fix:** A web service account like `svc-web` should **never** possess `SeDebugPrivilege` by default. The remediation consists of auditing the process tree to verify if this privilege was inherited from an overly permissive parent account. If the application requires inspection rights, privilege separation must be implemented by creating an isolated monitoring sub-component running under a distinct, restricted account, while the process handling public HTTP traffic is completely stripped of it. Furthermore, enabling **LSASS RunAsPPL** protection in the Windows registry will prevent even users with `SeDebugPrivilege` from reading the memory of the main authentication process.

## 3. Defensive Visibility and Forensic Log Analysis

### A) Escalation via SeImpersonatePrivilege (PrintSpoofer)
*   **Action Performed:** Privilege escalation to `NT AUTHORITY\SYSTEM` by abusing `SeImpersonatePrivilege` through the Print Spooler named pipe using `PrintSpoofer`.
*   **Expected Security Log Evidence:** The privilege abuse itself is not recorded because `Privilege Use` auditing is disabled. However, this action results in a successful `SYSTEM` service logon, recorded as Event ID **4624 (Logon Type 5 - Service)** in the Windows Security log.
*   **Defensive Alerting:** Alert on unexpected Logon Type 5 service sessions originating from non-standard user accounts like `svc-web`.

### B) Escalation via SeDebugPrivilege (Memory Dumping)
*   **Action Performed:** Process memory access and extraction of SAM/SYSTEM registry hives from memory by abusing `SeDebugPrivilege`.
*   **Expected Security Log Evidence:** This decisive action is completely unrecorded in the Windows Security log because both `Privilege Use` and `Object Access` categories are explicitly configured as `No Auditing` on this host.
*   **Defensive Alerting:** Deploy EDR rules to trigger high-severity alerts when non-system service processes request `PROCESS_VM_READ` access rights to `lsass.exe`.

### C) Lateral Movement via wmiexec vs. smbexec
*   **Action Performed:** Remote command execution attempts using Impacket tools to establish operational shells.
*   **Expected Security Log Evidence:** Both tools are entirely unrecorded in the Windows Security log because `Detailed Tracking -> Process Creation` is set to `No Auditing`, preventing Event ID 4688 from generating. While `smbexec` populates Event ID 7045, this occurs exclusively within the System log, leaving the Security log completely empty.
*   **Defensive Alerting:** Implement centralized ingestion rules to trigger alerts when ephemeral system services or anomalous process lineages execute raw command lines containing binary redirection strings.

### D) Escalation Attempt via Remote Administrator (RID 500 Account)
*   **Action Performed:** Attempted administrative command execution and file system access using the remote built-in `Administrator` token.
*   **Expected Security Log Evidence:** The initial remote network authentication attempt is successfully captured as Event ID **4624 (Logon Type 3 - Network)** in the Windows Security log. The subsequent failed file access is not recorded because `Object Access -> File System` is set to `No Auditing`.
*   **Defensive Alerting:** Establish behavior-based detection metrics flagging recurrent network authentication sessions from local administrators that fail to touch targeted high-value objects.
