# Verdict Brief

## Current Security Posture
Tessara’s posture is informal [E01, E04, E07, E12] with systemic governance failures [E09, E12] and operational blind spots [E03, E06]. The company operates at NIST CSF 2.0 Tier 1 (Partial) [E01, E09] as core risk-management is neglected [E09, E12]. Lack of governance forces operations to rely on unmonitored systems and shared keys [E02, E03, E06]. Most critically, the Board deferred risk discussions for three quarters, leaving the firm without a risk strategy or registry [E09]. Consequently, critical phishing incidents are handled via improvisation without ticketing or post-incident review [E07].

## Top Security Gaps and Business Consequences
1. **Governance & Risk Strategy (GV.RM / GV.RR):** Deferral of risk oversight [E09] and absence of a CISO [E12] prevent proactive planning. **Business Consequence:** Caused procurement rejection by a prospect, costing a €900,000 contract.
2. **Identity & Access Lifecycles (PR.AA):** External contractors use unmanaged shared SSH keys [E02] and offboarding failures leave access active for 11 days [E04]. **Business Consequence:** Risks intellectual property theft, threatening operational downtime.
3. **Data Security Countermeasures (PR.DS):** Backups are executed [E05] but unmonitored configurations left two storage buckets publicly readable [E11]. **Business Consequence:** Threatens immediate regulatory penalties, GDPR fines, and loss of customer trust.

## The Twelve-Month Path to Certification
Tessara will use NIST CSF 2.0 to build an ISMS targeted for ISO/IEC 27001:2022 certification within 12 months. Months 1–3 (Stage 1 Readiness) establish governance, define scope, and formalize high-level policies. Months 4–6 (Internal Implementation) deploy technological controls, remediate identity lifecycles, and build an asset inventory. Months 7–9 (Internal Audit) establish an internal audit program and assess the Statement of Applicability (SoA). Months 10–12 (External Certification) conduct Stage 1 Audit in Month 10 and Stage 2 Audit in Month 12 for final certification.

## Immediate First 90 Days Actions
1. **Action 1 (Fixes GV.RM / GV.RR):** Appoint a risk owner and establish an unalterable quarterly schedule for Board risk reviews.
2. **Action 2 (Fixes PR.AA):** Implement an automated HR-to-IT offboarding workflow to revoke all logical access within 24 hours.
3. **Action 3 (Fixes PR.AA):** Revoke shared contractor SSH keys, migrate accounts to the central IdP, and mandate MFA.

## Resource and Cost Justification
Funding external certification body fees, staff effort, and a cloud security posture management tool is critical. The evidence screams for immediate action [E01, E02, E04, E07, E09, E11, E12] because paper compliance has backfired [E01, E02, E11] and the CTO spends zero formal time on security oversight [E12]. Spending €100,000 on this certification path is a direct business enabler that unlocks the currently blocked €900,000 enterprise pipeline [E09] and protects logistics revenue from operational disruptions.
