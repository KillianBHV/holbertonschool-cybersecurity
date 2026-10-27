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
*   **Action Performed:** Successful privilege escalation to `NT AUTHORITY\SYSTEM` by abusing `SeImpersonatePrivilege` through the Print Spooler named pipe using `PrintSpoofer`.
*   **Expected Log Evidence:** Since `Privilege Use -> Sensitive Privilege Use` is explicitly set to `No Auditing`, the direct invocation of the privilege is not recorded. However, the resulting context transition generates Event ID **4624 (Successful Logon)** with **Logon Type 5 (Service)** in the Security log.
*   **Defensive Alerting:** Monitor and alert on anomalies where a Logon Type 5 session or unexpected service thread execution is triggered directly by low-privileged application pools like `svc-web`.

### B) Escalation via SeDebugPrivilege (Memory Dumping)
*   **Action Performed:** Successful process memory access and extraction of SAM/SYSTEM registry hives from memory by abusing `SeDebugPrivilege`.
*   **Expected Log Evidence:** No event is generated in the Security log because both `Privilege Use` and `Object Access -> Kernel Object` are configured as `No Auditing` on this host. This decisive action leaves no direct trace in the Security logs due to these disabled features.
*   **Defensive Alerting:** Deploy endpoint detection (EDR) rules to trigger alerts whenever non-system binaries or web service accounts request handles with memory read access (`PROCESS_VM_READ`) to processes like `lsass.exe`.

### C) Lateral Movement via wmiexec vs. smbexec
*   **Action Performed:** Remote command execution attempts using Impacket tools to establish operational shells.
*   **Expected Log Evidence:** For `wmiexec`, the execution is completely invisible in the Security log because `Detailed Tracking -> Process Creation` is set to `No Auditing`, preventing Event ID 4688 from generating. For `smbexec`, the host successfully recorded Event ID **7045 (A new service was installed)** in the System log (under `Security State Change -> Success`), capturing the randomized service name `SCcGQDXs` executing `%COMSPEC%`.
*   **Defensive Alerting:** Configure SIEM rules to alert immediately on Event ID 7045 when the `Service File Name` pattern contains binary redirection operators or éphémère command strings (`%COMSPEC% /Q /c`) targeting administrative shares.

### D) Escalation Attempt via Remote Administrator (RID 500 Account)
*   **Action Performed:** Attempted administrative command execution and file system access using the remote built-in `Administrator` token.
*   **Expected Log Evidence:** The remote network authentication attempt is successfully recorded as Event ID **4624 (Logon Type 3 - Network)** in the Security log. However, the subsequent administrative file read attempt fails silently without an Event ID 4656/4663 failure log because `Object Access -> File System` is set to `No Auditing`.
*   **Defensive Alerting:** Since the kernel-level `LocalAccountTokenFilterPolicy` restricts the token silently without generating explicit intrusion events, defenders must implement behavior-based alerts flagging high-frequency network logons followed by subsequent operational failure anomalies.
