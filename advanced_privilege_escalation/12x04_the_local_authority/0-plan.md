# Plan

## Initial Assessment Strategy
To build an effective Windows escalation path, my first action on the host will be to inspect the current process token capabilities rather than local group memberships. I will execute `whoami /all` immediately upon gaining a foothold. This command is crucial because a Windows account's actual power is not described by its administrative group name, but by the specific privileges and integrity levels embedded inside its active security token. An account can belong to high-privilege groups while its current token remains strictly filtered and restricted by User Account Control (UAC).

## Overcoming the Linux Instinct
I am consciously setting aside the Linux instinct of hunting for writable directories, misconfigured cron jobs, or visible service binaries to exploit. In Windows, compromise is driven by token manipulation and impersonation. When the instinct to look for file system flaws pulls, I will instead systematically map the available token privileges (`SeImpersonatePrivilege`, `SeDebugPrivilege`). If these privileges are present, I will target the communication mechanisms of highly privileged processes, such as Named Pipes or memory spaces, to force them to interact with our foothold and hand over their security context.

## Handling an Immediate Whole Path
If the initial token assessment reveals that the foothold already holds a high-integrity token or a monumentally powerful privilege like `SeImpersonatePrivilege`, I will acknowledge that I am already holding the whole path to system compromise. Instead of wasting operational time searching for external vulnerabilities on the disk, I will immediately operationalize what I hold. I will execute local impersonation tools like `PrintSpoofer` or leverage native service behaviors to instantaneously duplicate a `NT AUTHORITY\SYSTEM` token, finalizing the escalation directly from the existing foothold context.
