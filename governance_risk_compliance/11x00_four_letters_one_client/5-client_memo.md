# EXECUTIVE COMPLIANCE - MEMORANDUM

**To:** Chief Executive Officer, Nordwell Technologies  
**From:** BEHAVA Killian, Junior GRC Consultant  
**Date**: Friday, October 9, 2026  
**Subject**: Strategic Compliance Mapping, Roadmap, and Immediate Operational Actions  

## 1. Regulatory and Contractual Mapping
Our upcoming expansion and client commitments trigger four distinct compliance frameworks, driven by three operational events:

*   **Hartwell Insurance ($1.2M ARR Deal):** Triggers **SOC 2**. This is enforced purely by **market and contract pressure** to clear their procurement blocker.
*   **Brightpath Health Network Contract:** Triggers **HIPAA** because we will process occupational-health and wellness metadata. This is enforced by **federal law** via the HHS Office for Civil Rights upon countersigning the required Business Associate Agreement **(BAA)**.
*   **Q4 EU Launch (France/Germany Pilot) & Self-Serve Tier:** Simultaneously triggers **GDPR** (enforced by **statutory law** through EU supervisory authorities for processing EU employee personal data) and **PCI DSS** (enforced by **industry contract** through card brands via acquiring banks for processing in-app card payments).

## 2. CPO Assumption Correction
The CPO's assumption that using an external payment provider completely exempts Nordwell from PCI DSS scope **is incorrect**. While utilizing an embedded checkout limits our technical footprint, Nordwell remains legally responsible for the **security of the integration** and **must maintain baseline compliance**, specifically by completing a **Self-Assessment Questionnaire (SAQ-A) and an Attestation of Compliance (AOC)**.

## 3. Justified Priority Roadmap
Based strictly on impending deadlines and financial or regulatory exposure, the execution order must be as follows:

1.  **Priority 1: Hartwell Insurance (SOC 2 Type II Report)**
    *   *Justification:* A mission-critical procurement blocker for a $1.2M ARR deal with a strict **6-week deadline**.
    *   Failure results in direct, immediate revenue loss.
2.  **Priority 2: Brightpath Health Network (HIPAA BAA)**
    *   *Justification:* **8-week deadline**.
    *   Processing medical-note metadata without an executed BAA creates immediate statutory liability under the historical HIPAA Security Rule text, which remains fully in force as the active enforceable standard while the technical overhaul continues to be delayed.
3.  **Priority 3: EU Launch & Self-Serve Tier (GDPR & PCI DSS)**
    *   *Justification:* Tied to the broader **Q4 deadline**.
    *   Non-compliance with GDPR carries immediate statutory risk with potential statutory fines up to €20 million or 4% of global annual turnover, while PCI DSS Version 4.0 is fully mandatory and the sole active version since March 31, 2025.
    *   However, it possesses the longest timeline buffer.

## 4. Immediate Next Actions *(Monday Morning)*
To meet these targets, the following concrete actions must be executed immediately on Monday morning:

*   **SOC 2 (Hartwell):** Engage our external auditor to establish a formal compliance roadmap and finalize the system description to present a SOC 2 Type I report as an interim bridge to clear the procurement blocker within 6 weeks.
*   **HIPAA (Brightpath):** Instruct the legal team to countersign the Business Associate Agreement (BAA) and simultaneously launch our internal technical team on a formal Security Risk Analysis to validate the metadata handling before the 8-week go-live.
*   **GDPR & PCI DSS (EU/Self-Serve):** Initiate the creation of our formal Record of Processing Activities (ROPA) for the France and Germany pilot customers, and schedule a technical review of the embedded checkout architecture to prepare the PCI DSS SAQ-A documentation.
