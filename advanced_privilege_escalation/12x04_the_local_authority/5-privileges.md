# The Privilege Abuse Map

## 1. Initial Token Privileges

The initial token associated with the `svc-web` service account presented a critical attack surface with five enabled privileges. The detailed analysis of each privilege, its exploitation potential, and its role in our intrusion highlights the major gap between the perimeter-based vision of Vantage administrators and the technical reality of intrinsic system rights.

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

### Scenario A: Impersonation Exploitation (PrintSpoofer)
*   **Log Visibility:** Partial. Escalation via `SeImpersonatePrivilege` generates a context transition.
*   **Key Event:** Event ID **4624 (An account was successfully logged on)** is generated in the *Security* log. However, instead of a classic network session (Type 3) or interactive session (Type 2), the defender will observe a **Type 5 (Service)** session or a thread identity change. Event ID **4672 (Special privileges assigned to new logon)** will also be recorded when the session is created, indicating that `SYSTEM` privileges were invoked by a locally initiated process.

### Scenario B: Remote Access via wmiexec and smbexec
*   **Log Visibility:** High for `smbexec`, stealthy for `wmiexec`.
*   **Key Event (smbexec):** The `smbexec` tool creates an ephemeral Windows service. The *System* log records Event ID **7045 (A new service was installed)**. The defender will see a randomized service name executing a cmd.exe command that redirects output to an administrative share.
*   **Key Event (wmiexec):** More subtle, it leverages the legitimate `WmiPrvSE.exe` process. In the *Security* log, Event ID **4688 (A new process has been created)** will show that the parent process `WmiPrvSE.exe` spawned a child process `cmd.exe` or `powershell.exe`. This is a Living Off The Land (LotL) indicator of anomalous activity.

### Scenario C: The Administrator's Filtered Token (RID 500 Account)
*   **Log Visibility:** Invisible during file access, visible during network logon.
*   **Key Event:** When we attempted to access the file system using the remote `Administrator` account and received an "Access Denied", no specific alert event was generated outside of object access audit logs (if specifically enabled, ID 4656/4663). The remote UAC filtering mechanism (*LocalAccountTokenFilterPolicy*) enforces a restriction at the OS kernel level. In the authentication logs (ID 4624), the session appears as successful (Type 3 - Network), but the resulting token is transparently restricted by Windows. This explains why the administrator faces a group marked as *Deny Only* without triggering an explicit intrusion-type security alert.
