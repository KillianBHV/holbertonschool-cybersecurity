# Verdict Brief

## Current Security Posture
Tessara’s current security posture is fundamentally informal [E01, E04, E07, E12], characterized by systemic governance failures [E09, E12] and operational blind spots [E03, E06]. The organization operates at NIST CSF 2.0 Tier 1 (Partial) across all functions because core risk-management practices have been neglected [E09, E12]. This complete lack of governance trickles down to operations, forcing teams to rely on unmonitored systems and shared keys [E02, E03, E06]. Most critically, the Board has deferred necessary risk discussions for three consecutive quarters, leaving the company with zero formal risk-management strategy or registry [E09]. This operational baseline means critical incidents—such as a recent Slack phishing attack—are handled through individual improvisation without formal ticketing, logging, or post-incident review [E07].

## Top Security Gaps and Business Consequences
1. **Governance & Risk Strategy (GV.RM / GV.RR):** The deferral of risk oversight [E09] and the complete absence of a Chief Information Security Officer (CISO) or defined security roles [E12] prevent proactive security planning.  
   **Business Consequence:** This governance failure directly led to a procurement rejection by a major prospect, costing Tessara a €900,000 contract due to unverified security practices.
2. **Identity & Access Lifecycles (PR.AA):** Administrative interfaces lack uniform access control, exemplified by external contractors using unmanaged, shared SSH keys [E02], and the lack of a formal offboarding process leaving access active for 11 days post-termination [E04].  
   **Business Consequence:** Delayed access revocation poses a direct risk of intellectual property theft and unauthorized system modifications, threatening catastrophic operational downtime.
3. **Data Security Countermeasures (PR.DS):** While technical backups are correctly executed and tested [E05], cloud configurations are unmonitored, which previously resulted in two object storage buckets being left exposed to the public internet [E11].  
   **Business Consequence:** Publicly exposed data buckets expose the firm to mandatory regulatory penalties, severe GDPR fines, and a direct loss of enterprise customer trust.

## The Twelve-Month Path to Certification
Tessara will utilize the NIST CSF 2.0 framework as its operational guide to build a robust Information Security Management System (ISMS) capable of achieving ISO/IEC 27001:2022 certification within twelve months.
* **Months 1–3 (Stage 1 Readiness):** Establish core governance, define the ISMS scope, and formalize all mandatory high-level policies.
* **Months 4–6 (Internal Implementation):** Deploy technological controls, clean up identity lifecycles, and build a comprehensive asset inventory.
* **Months 7–9 (Internal Audit):** Establish a formal internal audit program, appoint competent internal auditors, and conduct a full assessment against the Statement of Applicability (SoA).
* **Months 10–12 (External Certification):** Engage an accredited external certification body. Conduct the Stage 1 Audit (documentary review) in Month 10, followed by the Stage 2 Audit (operational verification) in Month 12 to secure the official certificate.

## Immediate First 90 Days Actions
1. **Action 1 (Fixes GV.RM / GV.RR):** Formally establish the internal audit program framework, appoint a dedicated risk owner, and lock in an immutable quarterly schedule for Board risk reviews.
2. **Action 2 (Fixes PR.AA):** Implement a strict, automated HR-to-IT offboarding ticket workflow ensuring all logical accesses are revoked within 24 hours of an employee's departure.
3. **Action 3 (Fixes PR.AA):** Revoke all shared SSH keys used by external contractors, migrate their authentication to the central Identity Provider (IdP), and mandate Multi-Factor Authentication (MFA).

## Resource and Cost Justification
Achieving this roadmap requires funding external certification body fees, dedicating internal staff hours, and establishing an automated cloud security posture management tool. The evidence screams for immediate action: Tessara has already proven that a paper-compliance strategy backfires [E01, E02, E11], and the financial toll of doing nothing is clear. Spending an estimated €100,000 on this certification path is a direct business enabler; it immediately unlocks the blocked €900,000 enterprise pipeline and protects the core logistics revenue from devastating operational disruptions.
