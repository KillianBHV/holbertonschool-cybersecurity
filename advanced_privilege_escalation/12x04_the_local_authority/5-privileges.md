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

### A) Impersonation Exploitation (PrintSpoofer)
*   **Recording Layer:** Local auditing for the `Privilege Use` category is set to `No Auditing`. Thus, the invocation of `SeImpersonatePrivilege` did not generate local security events. However, the subsequent network context change generated Event ID **4624 (Successful Logon)** with a **Logon Type 5 (Service)**.
*   **Alerting Layer:** A generic Logon Type 5 event is common and will not trigger a SIEM alert. Vantage defenders must build custom alert logic targeting atypical thread handovers or service logons initiated directly by the `svc-web` application pool.

### B) Remote Access via wmiexec vs. smbexec
*   **Recording Layer:** Local verification shows that `Detailed Tracking -> Process Creation` is set to `No Auditing`. Consequently, commands executed via `wmiexec` (spawning `cmd.exe` under `WmiPrvSE.exe`) are **completely invisible**; running `Get-WinEvent` for Event ID 4688 confirmed no modern process logs exist. 
    Conversely, the host's policy enforces `System -> Security State Change -> Success`. Active log inspection confirmed that **`smbexec` left a critical trail of Event ID 7045 (New Service Installed)** in the System log. The host successfully captured randomized service names (e.g., `SCcGQDXs`) executing command blocks redirecting outputs to administrative shares: `%COMSPEC% /Q /c echo type ...`.
*   **Alerting Layer:** While `wmiexec` remains silent due to disabled auditing, `smbexec` provides an explicit signature. Defenders must configure a high-severity SIEM alert targeting any Event ID 7045 where the `Service File Name` contains `%COMSPEC% /Q /c` or redirects output using command-line operators (`^? \\%COMPUTERNAME%\C$`) to administrative shares.

### C) The Administrator's Filtered Token (RID 500 Account)
*   **Recording Layer:** Local configuration for `Object Access -> File System` is set to `No Auditing`. When we faced an "Access Denied" error attempting to read `system_proof.txt`, the host **did not record** any file access failure events (Event ID 4656/4663). The network logon was recorded as an Event ID 4624 (Logon Type 3).
*   **Alerting Layer:** The restriction occurs silently at the kernel level via `LocalAccountTokenFilterPolicy` forcing a filtered UAC token. Because Windows treats this restriction as a standard access control rejection rather than a security anomaly, **no defensive alerts are generated by default**. Defenders must flag recurring network authentication trends from administrative accounts that experience high rates of subsequent file system access rejections.
