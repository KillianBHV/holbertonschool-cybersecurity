# Security Architecture Defense
## Challenge 1: Risk Acceptance
### Business Constraint Analysis

The project requirements explicitly stated that FTP services used by the Finance department must remain operational. While migrating directly to SFTP would provide a stronger long-term security posture, forcing an immediate protocol change could disrupt critical business processes and introduce operational risk.
The primary objective of this engagement was to improve security without breaking production services. Therefore, maintaining FTP availability was considered a mandatory business constraint.

## Risk Mitigation Measures Implemented
> Several compensating controls were implemented to reduce the risk associated with retaining FTP:
* FTP access is no longer exposed directly to untrusted networks.
* Access is restricted through a VPN connection.
* Only authorized Finance users can reach the FTP service.
* Firewall rules enforce least-privilege access.
* Network segmentation limits exposure of the FTP server.
* Logging and monitoring were enabled to improve visibility into FTP-related activity.
* Default-deny firewall policies prevent unauthorized access paths.
> These controls significantly reduce the attack surface compared to the original environment.

### Residual Risk Acknowledgment
> Residual risk remains because FTP was not designed to provide modern security guarantees.
Potential concerns include:
* Legacy protocol weaknesses.
* Dependence on compensating controls rather than protocol-level security.
* Increased maintenance complexity compared to a native secure protocol.
> This residual risk has been formally accepted due to business requirements and implementation constraints.

### Recommendation
> The recommended long-term solution is a phased migration from FTP to SFTP.
Proposed Phase 2 activities:
1. Inventory all FTP-dependent workflows.
2. Validate SFTP compatibility with business applications.
3. Conduct pilot testing with Finance users.
4. Migrate users and services gradually.
5. Decommission FTP after successful validation.
This approach removes the residual protocol risk while minimizing operational disruption.

## Challenge 2: Firewall Strategy
### Zone Definitions and Trust Levels
> The redesigned architecture follows Zero Trust principles and separates the environment into distinct security zones:

| Zone | Trust Level                  | Purpose                                 |
| ---- | ---------------------------- | --------------------------------------- |
| WAN  | Untrusted                    | External networks and Internet          |
| DMZ  | Limited Trust                | Public-facing and intermediary services |
| VPN  | Authenticated but Restricted | Remote user access                      |
| LAN  | Trusted Internal Resources   | Business systems and databases          |

> No zone is trusted implicitly.

### Traffic Flow Restrictions
> Traffic is only allowed when explicitly required.
Examples include:
* VPN users may access approved internal resources only.
* DMZ systems cannot freely initiate connections into the LAN.
* Database access is limited to authorized application systems.
* Unspecified traffic is denied by default.
> All inter-zone communication requires explicit authorization.

### How the Previous Attack Path Is Blocked
> The original breach leveraged excessive network trust and unrestricted lateral movement.
In the redesigned architecture:
* Internal resources are segmented into separate security zones.
* Default-deny policies block unauthorized east-west traffic.
* VPN users do not receive unrestricted LAN access.
* Access rights are restricted according to business roles.
* Firewall enforcement points inspect all cross-zone traffic.
> An attacker who compromises one system can no longer move freely throughout the environment.

### Defense-in-Depth Principles Applied
> The design incorporates multiple overlapping security controls:
* Network segmentation.
* Stateful firewall filtering.
* VPN authentication.
* Least-privilege access controls.
* Service hardening.
* Monitoring and logging.
* Secure administrative access.
> No single control is relied upon as the sole line of defense.

## Challenge 3: Resilience

#### Question

*"The Gateway is still a Single Point of Failure. What happens if it goes down?"*

### Scope Acknowledgment
The observation is correct.
The current gateway remains a Single Point of Failure (SPOF).
However, the project scope focused on security remediation and risk reduction rather than high-availability architecture redesign.
Implementing redundancy would require additional infrastructure, budget, testing, and operational planning beyond the scope of this engagement.

### Current Risk Exposure
> If the gateway becomes unavailable:
* VPN access is interrupted.
* External connectivity may be impacted.
* Access to services traversing the gateway may be unavailable.
> While security remains intact, service availability could be affected.

### High-Level HA Plan
> A future high-availability implementation could include:
* Secondary gateway deployment.
* Firewall failover clustering.
* Redundant VPN services.
* Configuration synchronization between gateways.
* Health monitoring and automatic failover.
> This would remove the gateway as a single point of failure.

### Cost-Benefit Analysis
The current design prioritizes security improvements while minimizing deployment complexity and implementation risk.
Introducing full high availability would provide greater resilience but would also increase:
* Infrastructure costs.
* Operational complexity.
* Maintenance requirements.
* Testing and validation effort.

Given the project objectives, security remediation was prioritized first. High availability is recommended as a Phase 2 enhancement once the new security baseline has been stabilized and validated.
