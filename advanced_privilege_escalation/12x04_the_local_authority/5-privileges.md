# The Privilege Abuse Map

## 1. Initial Token Privileges

*   **SeDebugPrivilege (Used):** This privilege allows inspecting and modifying the memory of any process, including `lsass.exe`. We actively exploited it to bypass standard access controls by reading the memory of third-party processes and extracting sensitive SAM and SYSTEM hives necessary for our lateral movement.
*   **SeImpersonatePrivilege (Used):** Designed to allow a service account to create a thread within a client's security context, this privilege can be weaponized if a highly privileged process interacts with our service. We used it via `PrintSpoofer` to impersonate the Windows Print Spooler service, triggering an instantaneous privilege escalation to obtain an `NT AUTHORITY\SYSTEM` security token.
*   **SeBackupPrivilege (Unused):** This privilege bypasses file ACLs to read any element on the disk for backup purposes. While powerful for exfiltrating the SAM database and the SYSTEM hive for offline hash cracking, we did not actively enable it because bypassing via impersonation and direct memory access proved faster and more stable.
*   **SeChangeNotifyPrivilege (Unused):** This right allows receiving file change notifications and traversing folders even if the user lacks explicit read permissions on the parent folder. This standard privilege is granted by default to almost all Windows users for normal OS operation. It offers no direct path to privilege escalation and was not exploited.
*   **SeIncreaseWorkingSetPrivilege (Unused):** This privilege allows a process to increase its physical working memory size. Used by resource-intensive applications to improve performance, it offers no attack vector or security bypass. It remained unused as it provides no value in a privilege escalation scenario.

## 2. Critical Escalation Paths

### A) Abuse of SeImpersonatePrivilege via PrintSpoofer
Exploiting `SeImpersonatePrivilege` via a Named Pipe tied to the print spooler allowed a full compromise of the machine up to the `SYSTEM` level. 
*   **The Simplistic Remediation Trap:** Removing `SeImpersonatePrivilege` from `svc-web`. This account runs a web server (IIS) that strictly requires this privilege to authenticate web users and execute requests on their behalf. Removing this right would immediately paralyze the application.
*   **Realistic Production Fix:** Disable the Print Spooler service on this server if it has no printing function. If printing is required, named pipe creation permissions must be hardened via local policies, or the web process must be isolated within a dedicated application container with inter-process communication restrictions.

### B) Global Memory Access via SeDebugPrivilege
The `SeDebugPrivilege` privilege allowed violating the memory space of other processes to gather secrets and map permissions.
*   **The Simplistic Remediation Trap:** Removing the privilege globally. Certain monitoring agents, critical backup tools, or deeply integrated web server APM tools require it for low-level diagnostic tasks in production.
*   **Realistic Production Fix:** A web service account like `svc-web` should never possess `SeDebugPrivilege` by default. Audit the process tree to verify if this privilege was inherited from an overly permissive parent account. If inspection rights are required, implement privilege separation by creating an isolated monitoring sub-component running under a distinct account, while the process handling public HTTP traffic is completely stripped of it. Furthermore, enable **LSASS RunAsPPL** protection in the registry to prevent users with `SeDebugPrivilege` from reading the memory of the main authentication process.

## 3. Defensive Visibility and Forensic Log Analysis

### A) Impersonation Exploitation (PrintSpoofer)
*   **Action Performed:** Privilege escalation to `NT AUTHORITY\SYSTEM` by abusing `SeImpersonatePrivilege` through the Print Spooler named pipe using `PrintSpoofer`.
*   **Expected Security Log Evidence:** Host-observed `auditpol` outputs confirm `Privilege Use` is set to `No Auditing`, meaning no event records the physical invocation. However, the post-escalation network service mapping records a successful `SYSTEM` context entry, visible as Event ID **4624 (Logon Type 5 - Service)** in the local Security log.
*   **Defensive Alerting:** A Logon Type 5 event is routinely logged for benign background services and will not alert on its own. Defenders must deploy custom rules to trigger alerts when an unexpected Logon Type 5 session originates from non-standard accounts like `svc-web`.

### B) Escalation via SeDebugPrivilege (Memory Dumping)
*   **Action Performed:** Process memory access and extraction of SAM/SYSTEM registry hives from memory by abusing `SeDebugPrivilege`.
*   **Expected Security Log Evidence:** Host checks via `auditpol /get /category:*` confirm `Privilege Use` and `Object Access` are set to `No Auditing`. Consequently, this action fails to log any events in the Windows Security log. The dump executes without leaving local cryptographic or audit tracking records.
*   **Defensive Alerting:** Because the Security log remains blind, traditional logging cannot trigger alerts. Vigilance relies entirely on EDR rules configured to alert when low-privilege application processes request `PROCESS_VM_READ` handles targeting `lsass.exe`.

### C) Lateral Movement via wmiexec vs. smbexec
*   **Action Performed:** Remote command execution attempts using Impacket tools to establish operational shells.
*   **Expected Security Log Evidence:** For `wmiexec`, execution is hidden; running `Get-WinEvent` for Event ID 4688 verified that `Detailed Tracking -> Process Creation` is set to `No Auditing`. Conversely, `smbexec` leaves a clear footprint. Active inspection confirmed `smbexec` generated Event ID **7045 (A service was installed in the system)** within the System log, capturing the randomized service name `SCcGQDXs` and the command string executing `%COMSPEC% /Q /c`.
*   **Defensive Alerting:** While `wmiexec` registers no process logs, `smbexec` provides an indicator. Defenders should configure SIEM systems to ingest System logs and alert when Event ID 7045 features a `Service File Name` pattern containing `%COMSPEC% /Q /c` with redirection operators pointing to administrative shares.

### D) Escalation Attempt via Remote Administrator (RID 500 Account)
*   **Action Performed:** Attempted administrative command execution and file system access using the remote built-in `Administrator` token.
*   **Expected Security Log Evidence:** The initial remote network authentication maps to the Security log as Event ID **4624 (Logon Type 3 - Network)**. However, the subsequent file read attempt is blocked silently without generating access failure events because `Object Access -> File System` is verified as `No Auditing`.
*   **Defensive Alerting:** The UAC restriction occurs silently at the kernel level via `LocalAccountTokenFilterPolicy`. To achieve visibility, defenders must implement behavior-based alerting targeting administrative accounts that maintain active Logon Type 3 sessions but generate subsequent operational anomalies on targeted high-value directories.
