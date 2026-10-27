# The Privilege Abuse Map

## 1. Initial Token Privileges

The initial token associated with `svc-web` presented a critical attack surface with five enabled privileges. The analysis of these rights highlights the major gap between perimeter-based active directory visions and the technical reality of local system rights.

*   **SeDebugPrivilege (Used):** This privilege allows inspecting and modifying the memory of any process, including `lsass.exe`. We actively exploited it to read the memory of third-party processes, extracting sensitive SAM and SYSTEM hives to perform lateral movement.
*   **SeImpersonatePrivilege (Used):** Designed to create a thread within a client's security context, this privilege can be weaponized if a highly privileged process interacts with our service. We used it via `PrintSpoofer` to impersonate the Windows Print Spooler, obtaining a high-integrity `NT AUTHORITY\SYSTEM` token.
*   **SeBackupPrivilege (Unused):** Bypasses file ACLs to read any element on the disk for backup purposes. While powerful for exfiltrating the SAM database and SYSTEM hive for offline cracking, it was redundant since direct memory access and impersonation paths were more stable.
*   **SeChangeNotifyPrivilege (Unused):** Allows traversing folders even if the user lacks explicit read permissions on the parent directory. This standard right is granted by default to almost all users for normal OS operation and offers no escalation path.
*   **SeIncreaseWorkingSetPrivilege (Unused):** Allows a process to increase its physical working memory size. Used by resource-intensive applications to improve performance, it offers no attack vector or security bypass.

## 2. Escalation Paths and Production-Safe Remediations

Blindly stripping rights would break Vantage's web platform. Below is the analysis of the two critical paths and their production-safe remediations.

### A) Abuse of SeImpersonatePrivilege via PrintSpoofer
Exploiting `SeImpersonatePrivilege` allowed a full compromise up to `SYSTEM`. 
*   **The Remediation Trap:** Removing `SeImpersonatePrivilege` from `svc-web` would paralyze the underlying web application (IIS), which strictly requires this privilege to authenticate web users and handle HTTP requests.
*   **Production Fix:** Disable the Print Spooler service (`Spooler`) on this host since it serves no business printing function. If printing is required, named pipe creation permissions must be hardened via local policies or the web process isolated within a restricted container.

### B) Global Memory Access via SeDebugPrivilege
`SeDebugPrivilege` allowed violating process memory space to gather system credentials.
*   **The Remediation Trap:** Removing the privilege globally can crash third-party system monitoring agents or backup software that require low-level diagnostics.
*   **Production Fix:** Explicitly strip `SeDebugPrivilege` from the `svc-web` service account. Implement strict privilege separation so that the public web process lacks it completely. Additionally, enable **LSASS RunAsPPL** protection in the Windows registry to shield the authentication sub-system from memory injection.

## 3. Defensive Visibility and Forensic Log Analysis

An assessment of the host's actual local audit policy (`auditpol /get /category:*`) and active logs was performed to bridge the gap between theoretical windows capabilities and host-specific evidence.

### Scenario A: Impersonation Exploitation (PrintSpoofer)
*   **Recording Layer:** Local auditing for the `Privilege Use` category is set to `No Auditing`. Thus, the invocation of `SeImpersonatePrivilege` did not generate local security events. However, the subsequent network context change generated Event ID **4624 (Successful Logon)** with a **Logon Type 5 (Service)**.
*   **Alerting Layer:** A generic Logon Type 5 event is common and will not trigger a SIEM alert. Vantage defenders must build custom alert logic targeting atypical thread handovers or service logons initiated directly by the `svc-web` application pool.

### Scenario B: Remote Access via wmiexec vs. smbexec
*   **Recording Layer:** Local verification shows that `Detailed Tracking -> Process Creation` is set to `No Auditing`. Consequently, commands executed via `wmiexec` (spawning `cmd.exe` under `WmiPrvSE.exe`) are **completely invisible**; running `Get-WinEvent` for Event ID 4688 confirmed no modern process logs exist. 
    Conversely, the host's policy enforces `System -> Security State Change -> Success`. Active log inspection confirmed that **`smbexec` left a critical trail of Event ID 7045 (New Service Installed)** in the System log. The host successfully captured randomized service names (e.g., `SCcGQDXs`) executing command blocks redirecting outputs to administrative shares: `%COMSPEC% /Q /c echo type ...`.
*   **Alerting Layer:** While `wmiexec` remains silent due to disabled auditing, `smbexec` provides an explicit signature. Defenders must configure a high-severity SIEM alert targeting any Event ID 7045 where the `Service File Name` contains `%COMSPEC% /Q /c` or redirects output using command-line operators (`^? \\%COMPUTERNAME%\C$`) to administrative shares.

### Scenario C: The Administrator's Filtered Token (RID 500 Account)
*   **Recording Layer:** Local configuration for `Object Access -> File System` is set to `No Auditing`. When we faced an "Access Denied" error attempting to read `system_proof.txt`, the host **did not record** any file access failure events (Event ID 4656/4663). The network logon was recorded as an Event ID 4624 (Logon Type 3).
*   **Alerting Layer:** The restriction occurs silently at the kernel level via `LocalAccountTokenFilterPolicy` forcing a filtered UAC token. Because Windows treats this restriction as a standard access control rejection rather than a security anomaly, **no defensive alerts are generated by default**. Defenders must flag recurring network authentication trends from administrative accounts that experience high rates of subsequent file system access rejections.
