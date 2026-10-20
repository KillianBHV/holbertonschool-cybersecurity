# Cyber Exploitation & Detection Report

## Part 1: The Wildcard Tar Execution Chain (Root Privilege Escalation)

The first exploitation path leverages a dangerous combination of a **privileged scheduled task** and **insecure directory permissions**, creating an arbitrary command execution vector as the `root` user. The vulnerability chain consists of two primary primitives:
* An **automated cron job** running with `root` authority that handles unanchored wildcard expansions.
* A **directory writable** by a lower-privileged service account (`svc-report`).

Neither primitive is sufficient to compromise the system on its own. The root cron job alone cannot be exploited because, without malicious filenames present in the target directory, the `tar` utility receives normal file arguments and cannot be steered into command execution. Conversely, write access alone within the writable directory cannot elevate privileges without a privileged process later consuming the directory contents with unsafe wildcard expansion.

The critical hazard emerges from their **composition**: 
1. The script changes its working directory to the user-controlled folder `/srv/mdx/reports/outbound`.
2. It executes `tar czf [archive] *`. 

Because the shell expands the wildcard `*` before passing the resulting list to the `tar` binary, an unprivileged user can manipulate the **command-line arguments** passed to the `root`-executed process.

By generating files named `--checkpoint=1` and `--checkpoint-action=exec=sh payload.sh` within that directory, the low-privileged user forces the `root` shell to translate the wildcard into discrete command arguments. When the cron job executes every three minutes, `tar` parses these injected filenames as **operational switches** rather than literal files to archive. This instructs the utility to execute the accompanying `payload.sh` script with `root` privileges at the first checkpoint interval, allowing the low-privileged account to copy `/root/proof/root.token` directly into a readable location.

### Audit Artifacts and Behavioral Detection

During the exploitation of this chain, the underlying operating system generates specific **event telemetry**. The `execve` system calls record the execution of the shell script by `cron`, followed immediately by the invocation of `tar` with an **anomalously structured argument vector** containing flag injections.

A robust, **behavior-based detection rule** must focus on the underlying execution mechanism rather than static elements like script names. The rule should trigger when:
* An archiving utility (`tar`, `7z`, `zip`) is spawned by a highly privileged user identifier (`uid=0`).
* The execution originates from within a path that is **world-writable** or owned by a non-administrative account.
* The command-line arguments contain patterns where **parameter-defining characters** (such as hyphens) are passed via automated wildcard expansions, or when execution-triggering arguments (like `exec=`) are observed in non-standard execution paths.

## Part 2: The Privileged Capability Information Disclosure Chain (Audit Log Inspection)

The second exploitation path focuses on bypassing **system isolation** to extract high-value forensic data from restricted audit logs. This chain relies on the composition of an over-privileged system utility and **insecure logging visibility configurations**. The two primitives involved are:
* The presence of a specialized binary (`mdx-fetch`) possessing **advanced filesystem capabilities**.
* The storage of sensitive command-line parameters inside the system audit trails (`auditd.log`).

Neither primitive is sufficient to produce the specific outcome of discovering the hidden token from audit logs on its own. The capability-enabled reader alone fails because, without sensitive audit content containing exposed command parameters, the utility has no operational trails to parse and cannot independently reveal the hidden token. Conversely, the sensitive audit content alone cannot be read or used because it is strictly protected by standard Discretionary Access Control (DAC) permissions, making the logs completely unreachable to an unprivileged account without the capability override to bypass those restrictions.

However, when these primitives interact, the **security boundary collapses**. An unprivileged user can leverage `mdx-fetch` to read files that bypass standard DAC restrictions completely, transforming a file-reading utility into a mechanism for **deep system reconnaissance**.

By utilizing this capability-enhanced tool, the attacker:
1. Reads `/etc/audit/auditd.conf` to map out the logging infrastructure.
2. Accesses the rotated raw audit logs located at `/var/log/audit/auditd.log.3`.

Regular users are barred from viewing these logs to prevent them from discovering system secrets or monitoring other users' activities. Through this access, the attacker reviews historical execution logs (`type=EXECVE`) and discovers an automated routine where a cleanup process searches for and deletes files matching a specific pattern: `find /tmp -name .mdx-cache.* -delete`. The precise cache filename revealed within the log acts as a **hidden token**, completing the objective.

### Audit Artifacts and Behavioral Detection

The exploitation of this capability chain leaves explicit markers in the system's operational logs. The **process tracking subsystems** record an unprivileged user session executing a binary that asserts elevated file-system read capabilities to access protected log directories and administrative configuration maps.

A behavior-based detection rule designed to catch this technique must key on the **mechanism of capability abuse** rather than specific binary names like `mdx-fetch`. The rule should monitor for:
* Any **process lifecycle events** where a non-root user account launches an application that inherits or invokes `CAP_DAC_READ_SEARCH` or `SUID` rights.
* Attempts to open files inside strictly protected system paths, such as `/var/log/audit/` or `/etc/audit/`.

By alerting on low-privilege accounts using **capability overrides** to access administrative log structures, security teams can detect credential or information exposure vectors before they are leveraged for broader lateral movement.
