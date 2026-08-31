# Vanguard Security: Threat Modeling Engagement Report
## Client: Meridian Federal Bank

**Prepared by:** BEHAVA Killian, Junior Consultant  
**Date:** 08-30-2026  
**Distribution:** Meridian internal architecture team

## 1. Executive Summary
This report delivers an engineering-centric threat model targeting the active multi-year cloud migration at Meridian Federal Bank. As the architecture transitions from a legacy mainframe to a hybrid AWS environment, the six-week dual-running synchronization window introduces a highly transient and elevated attack surface. This engagement systematically mapping core technical boundaries to mitigate critical risk vectors before legacy decommissioning. The recommendations contained herein provide direct, actionable engineering requirements to ensure data integrity and continuous compliance across all hybrid data flows.

## 2. Engagement Context
Meridian Federal Bank is currently mid-way through a critical infrastructure migration, shifting core banking assets from an on-premises legacy mainframe to a hybrid AWS architecture. This technical transition introduces a high-risk, six-week dual-running period where data must be continuously replicated and synchronized between environments. The purpose of this audit is to identify, analyze, and catalog the technical risks introduced during this transition state, ensuring that security controls are natively embedded into the hybrid design before the legacy systems are formally decommissioned.

## 3. Framework Choice and Rationale
The STRIDE framework was selected as the analytical engine for this engagement, prioritizing low-level architectural decomposition over high-level business abstractions. This approach directly contrasts with the methodologies applied in the recent **Sundara** and **Helix** engagements:
*   **Sundara** utilized a risk-centric framework focused primarily on compliance mapping and executive-level governance.
*   **Helix** leveraged an operational attack-tree methodology tailored for mature, static environments.

For Meridian, STRIDE is uniquely qualified because its element-by-element focus allows the engineering team to scrutinize the newly established trust boundaries between the legacy mainframe and the AWS DirectConnect/VPN link. By referencing specific workspace materials—notably the *Migration Architecture Diagram* and the *Rules of Engagement*—STRIDE ensures that every data store (such as the AWS S3 landing zones) and active process is systematically checked for technical flaws like data disclosure or unauthorized elevation of privilege during the migration window.

## 4. Threat Model
The following matrix represents the core technical findings derived from the STRIDE analytical phase, focusing exclusively on in-scope migration components:

| Element / Boundary | Threat Category | Threat Description |
| :--- | :--- | :--- |
| **Mainframe-to-AWS Hybrid Link** | Information Disclosure | Interception of unencrypted legacy replication protocols traversing the hybrid network boundary, exposing sensitive US customer banking data. |
| **Mainframe-to-AWS Hybrid Link** | Tampering | Unauthorized modification of financial records in transit during the dual-running synchronization phase due to a lack of cryptographic integrity checks. |
| **AWS S3 Data Landing Zone** | Information Disclosure | Misconfigured AWS IAM policies or overly permissive bucket access control lists (ACLs) exposing migrated financial assets to unauthorized internal users. |
| **AWS S3 Data Landing Zone** | Tampering | Malicious modification or encryption of historical transaction logs within the cloud landing zone prior to final legacy decommissioning. |
| **Branch Access Layer** | Elevation of Privilege | Local branch users or compromised workstations exploiting legacy authentication flaws to gain administrative roles within the new AWS web console. |

## 5. Recommendations and Prioritization
The following engineering-level remediations are prioritized by risk severity and require immediate implementation by the infrastructure team:

1.  **Enforce TLS 1.3 with Strict Certificate Pinning (High Priority)**  
    *Action:* Mandatory encryption of all data-in-transit across the hybrid link. Configure the legacy replication endpoints and the AWS ingestion gateways to reject any connections not utilizing TLS 1.3 with pre-approved, pinned certificates. This directly remediates the identified Information Disclosure threat.
2.  **Implement AWS IAM Least-Privilege & Mandatory MFA (High Priority)**  
    *Action:* Restrict all migration-specific IAM roles. Apply strict resource-based policies on the S3 Data Landing Zone buckets. Enforce hardware or virtual Multi-Factor Authentication (MFA) for all administrative accounts interacting with the AWS environment during the migration window.
3.  **Deploy WORM Storage Policies for Cloud Logs (Medium Priority)**  
    *Action:* Enable AWS S3 Object Lock in Compliance mode on all log buckets. This ensures transaction and synchronization logs are Write-Once-Read-Many (WORM), preventing any tampering or accidental deletion by legacy automated decommissioning scripts.

## 6. Limitations and Uncertainty
This threat modeling engagement is subject to specific scope and jurisdictional boundaries defined during project kickoff:
*   **Luxembourg Subsidiary Exclusion:** In strict accordance with the *Rules of Engagement* document clauses, the small European subsidiary in Luxembourg serving expatriate US clients is entirely excluded from this analysis. No assets, network segments, or regulatory profiles pertaining to the Luxembourg infrastructure were evaluated.
*   **Architecture Fluidity:** Because the system is currently mid-migration, certain cloud target configurations were analyzed as generic components based on intended design patterns rather than final static implementations.

## 7. Appendix: Sourced Findings
During the initial workspace exploration and analysis of the *Threat Intelligence Briefing on US financial-sector adversary activity*, a hidden technical alignment was identified:
*   **Sourced Threat Context:** Recent adversary campaigns targeting mid-sized regional banks heavily exploit weak boundary protections between legacy on-premises infrastructure and newly adopted public cloud platforms. This trend validates our high-priority focus on the hybrid link, as adversaries actively look for dual-running windows to intercept data streams before cloud native detection tools (like AWS GuardDuty) are fully configured and tuned.
