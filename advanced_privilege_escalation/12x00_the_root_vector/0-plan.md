# Engagement Plan: Non-Root Primitive Composition

## 1. System Inventory and Order of Execution
The assessment begins with a structured, manual enumeration targeted at mapping out local attack surfaces. The execution order focuses strictly on context and capability:
* **Session and Environment Context:** First, audit the current user identity, environmental variables, and group memberships to establish our baseline constraints.
* **Process and Task Schedules:** Second, examine active background processes, network sockets, and scheduled automations (cron jobs) looking for execution contexts that cross directory boundaries.
* **Filesystem and Binaries Privilege Audit:** Third, map directories writable by non-administrative accounts and inventory non-standard binaries possessing specialized attributes like SUID flags or Linux Extended Capabilities.

## 2. Determining Capabilities of Non-Documented Custom Binaries
To establish what an unrecorded custom binary actually permits without relying on external documentation, we isolate and observe its behavior:
* **Static Inspection:** Run `getcap` and `file` to verify compiled attributes and active capability sets (such as `CAP_DAC_READ_SEARCH`). Execute `strings` to identify hardcoded asset paths, configuration files, or parameters.
* **Dynamic Trace:** Execute the binary under system-call monitoring utilities like `strace` or `ltrace` while providing varied structural inputs. This reveals the exact system restrictions it attempts to bypass, what files it queries, and how it handles parameters.

## 3. Method for Handling Non-Root Privileged Primitives
When an isolated primitive grants an access vector or an intermediate identity that is not `root`, it is never treated as a dead end. Instead, it is approached as a structural pivot:
* The newly acquired privilege or data source becomes the active baseline. We rerun a targeted inventory from this updated context.
* We actively map how this intermediate state interacts with other distinct system layers, searching for structural compositions where a data-source primitive bridges into an execution-engine primitive.

## 4. Operational Restrictions
On this host, we will strictly **not execute automated, blind enumeration scripts** (such as LinPEAS). Relying on generalized tool outputs obscures custom logic, generates noisy indicators, and fails to map the deliberate relationship between complex primitives.
