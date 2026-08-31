## Framework Declaration
STRIDE

## Rationale
The selection of the STRIDE framework is driven by the transitional state of Meridian Federal Bank's infrastructure, which is undergoing a migration from a legacy mainframe to a hybrid AWS/on-premises architecture. STRIDE allows for an engineering-level, element-by-element decomposition of the hybrid data flows, which is critical during the six-week dual-running period. This framework ensures that trust boundaries between the legacy systems, the newly deployed AWS cloud components, and the on-premises environments are explicitly validated against technical risk vectors.

## Framework Selection Feedback
A core strength of STRIDE for this Meridian engagement is its granular focus on data-flow boundaries, making it highly effective at detecting data disclosure or spoofing risks during the high-risk dual-running migration window. However, a notable limitation is that STRIDE operates primarily at the technical component level; it has a blind spot regarding business-logic alignment and high-level regulatory compliance (such as SOX or GLBA tracking), which requires manual cross-referencing with business context documents.

## Threat Model
### 1. Legacy Mainframe to AWS DirectConnect / VPN (Trust Boundary)
*   **Spoofing:** Adversaries could impersonate legitimate on-premises services to send unauthorized synchronization commands to the AWS migration bucket.
*   **Tampering:** Unauthorized modification of financial records in transit during the dual-running replication phase due to weak transport encryption or missing integrity checks.
*   **Information Disclosure:** Eavesdropping on unencrypted legacy protocols traversing the hybrid network link, exposing sensitive US customer banking data.

### 2. AWS S3 Buckets / Data Landing Zone (Data Store)
*   **Information Disclosure:** Misconfigured S3 bucket permissions or broad IAM roles allowing public or unauthorized internal access to migrated financial assets.
*   **Tampering:** Ransomware or malicious actors modifying or encrypting historical transaction logs stored within the cloud landing zone before legacy decommissioning.
*   **Denial of Service:** Exhaustion of AWS resource quotas or targeted API flooding against cloud endpoints, disrupting the availability of the dual-running sync mechanisms.

### 3. On-Premises Customer/Branch Access Layer (Process/Actor)
*   **Repudiation:** Lack of comprehensive, immutable logging at the branch level during the dual-running phase, preventing forensic auditing of who initiated specific high-value transactions.
*   **Elevation of Privilege:** A local branch user exploiting legacy authentication mechanisms to gain unauthorized administrative roles within the new AWS web console or APIs.

## Identified Findings
1.  **Finding 1 [Priority: High]:** Missing end-to-end transport layer encryption (TLS 1.3) on legacy replication streams during the 6-week dual-running window, creating a high risk of Information Disclosure across the hybrid boundary.
2.  **Finding 2 [Priority: High]:** Over-permissive AWS IAM policies and lack of explicit multi-factor authentication (MFA) enforcement on migration administration roles, leading to potential Elevation of Privilege.
3.  **Finding 3 [Priority: Medium]:** Absence of write-once-read-many (WORM) configurations on AWS data landing zones, rendering transaction logs vulnerable to Tampering or deletion during decommissioning.
