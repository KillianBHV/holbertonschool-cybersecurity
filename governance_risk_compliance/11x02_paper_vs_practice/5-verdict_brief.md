# Verdict Brief

## Current Security Posture
Tessara’s security posture is fundamentally informal [E01, E04, E07, E12], showing systemic governance failures [E09, E12] and operational blind spots [E03, E06]. The company operates at NIST CSF 2.0 Tier 1 (Partial) because core risk-management is neglected [E09, E12]. Lack of governance forces operations to rely on unmonitored systems and shared keys [E02, E03, E06]. Most critically, the Board deferred risk discussions for three consecutive quarters, leaving the firm without a risk strategy or registry [E09]. Consequently, critical phishing incidents are handled via improvisation without formal ticketing or post-incident review [E07].

## Top Security Gaps and Business Consequences
1. **Governance & Risk Strategy (GV.RM / GV.RR):** Deferral of risk oversight [E09] and total absence of a CISO or defined security roles [E12] prevent proactive planning.  
   **Business Consequence:** This governance failure directly caused a procurement rejection by a major prospect, costing Tessara a €900,000 contract.
2. **Identity & Access Lifecycles (PR.AA):** Unmanaged shared SSH keys are used by external contractors [E02] and offboarding failures leave access active for 11 days [E04].  
   **Business Consequence:** Delayed access revocation risks intellectual property theft and unauthorized system changes, threatening catastrophic operational downtime.
3. **Data Security Countermeasures (PR.DS):** While backups are executed [E05], unmonitored cloud configurations previously left two storage buckets publicly readable [E11].  
   **Business Consequence:** Exposed data buckets threaten immediate regulatory penalties, severe GDPR fines, and a direct loss of enterprise customer trust.

## The Twelve-Month Path to Certification
Tessara will use NIST CSF 2.0 to build an ISMS targeted for ISO/IEC 27001:2022 certification within twelve months.
* **Months 1–3 (Stage 1 Readiness):** Establish governance, define ISMS scope, and formalize high-level policies.
* **Months 4–6 (Internal Implementation):** Deploy technological controls, remediate identity lifecycles, and build an asset inventory.
* **Months 7–9 (Internal Audit):** Establish an internal audit program and assess the Statement of Applicability (SoA).
* **Months 10–12 (External Certification):** Conduct Stage 1 Audit in Month 10 and Stage 2 Audit in Month 12 for final certification.

## Immediate First 90 Days Actions
1. **Action 1 (Fixes GV.RM / GV.RR):** Appoint a risk owner and establish an unalterable quarterly schedule for Board risk reviews.
2. **Action 2 (Fixes PR.AA):** Implement an automated HR-to-IT offboarding workflow to revoke all logical access within 24 hours.
3. **Action 3 (Fixes PR.AA):** Revoke shared contractor SSH keys, migrate accounts to the central IdP, and mandate MFA.

## Resource and Cost Justification
Funding external certification body fees, internal staff effort, and a cloud security posture management tool is critical. The evidence screams for immediate action: paper compliance has backfired [E01, E02, E11], and the CTO spends zero formal time on security oversight [E12]. Spending €100,000 on this certification path is a direct business enabler that unlocks the blocked €900,000 enterprise pipeline and protects logistics revenue from operational disruptions.
