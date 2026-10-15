# POST-INCIDENT VENDOR DECISION

**To:** Marlowe Retail Group Board of Directors  
**From:** Northbridge Risk Advisory  
**Date:** October 15, 2026  
**Subject:** Vendor Risk Verdict: Bracken Logistics & Solstice POS Concentration Flag  

### 1. Vendor Decision: Bracken Logistics (V5)
Following a comprehensive post-incident review at D+7, Northbridge recommends the conditional retention of Bracken Logistics (Inherent Risk Score: 11, Tier 2), subject to immediate contractual and operational remediations. This decision balances Bracken’s critical operational dependency (disrupts fulfillment within days) and low substitutability (migration takes weeks) against significant governance gaps identified in their historical SOC 2 Type II report:
* **Report Age:** The report on file covers the period ending April 30, 2025, representing a 14-month assurance gap at the review date (June 30, 2026).
* **Qualified Availability Opinion:** The auditor issued a qualified opinion for Availability due to a failed capacity-management control during Q1 of the review period.
* **Open Exception:** While two logical access control exceptions were remediated, one critical exception remained completely open at period end.
* **Carve-out Assurance Gap:** Primary datacenter operations are provided by a third-party hosting company and carved out of Bracken's report. Marlowe must immediately obtain the hosting provider’s own SOC 2 report to ensure complete end-to-end operational assurance.

### 2. Shared-Responsibility Admission & Remediation
The post-incident investigation confirms a critical internal failure within Marlowe’s own environment that directly contributed to the attack chain. Bracken’s SOC 2 report explicitly listed enforcement of multi-factor authentication (MFA) on customer portal accounts as a Complementary User Entity Control (CUEC). 
* **The Failure:** Marlowe never enabled or enforced MFA on its corporate portal accounts, leaving a clear unenforced CUEC in the kill chain. A consultant who edits the client's failure out of the record is decorating, not advising: this was a Marlowe control failure, not a vendor breach.
* **Remediation:** Marlowe’s IT Security team must enforce mandatory Tenant-Wide MFA across all active vendor portal connections, effective within 48 hours.

### 3. Required Contractual Amendments
The matching assessment from Task 2 identifies several critical contract clauses as **DEFANGED**. To maintain the engagement, Bracken must accept the following solid versions to protect Marlowe’s liability:
* **C2 - Annual Audit Right:** The current clause allows audits only with "Supplier's prior written approval". This must be amended to an absolute, un-vetoable right for Marlowe to conduct annual security audits upon a standard 60-day notice.
* **C3 - Liability Cap:** The current cap is defanged as it limits aggregate liability to fees paid in the mere 3 months preceding a claim. This must be replaced with a standard, solid liability cap equal to 12 months of contract value, with full carve-outs (uncapped liability) for data breaches and gross negligence.

### 4. Group Concentration Flag: Solstice POS (V6)
We raise an urgent, systemic risk flag regarding **Solstice POS** (Inherent Risk Score: 14, Tier 1), which handles point-of-sale software across all 340 stores. 
* **Financial Exposure:** A Solstice failure halts revenue operations within hours. Based on validated workshop baselines, the group's estate-wide exposure is **170 k€ per hour**, scaling to a massive **1 360 k€ for a standard 8-hour outage**.
* **Board Action Item:** To mitigate this extreme vendor concentration risk without incurring the prohibitive costs and operational friction of deploying a second parallel POS platform, the Board must fund and oversee the immediate deployment of an **offline store-and-forward capability**. This architectural mitigation ensures local tills continue processing transactions autonomously during a central Solstice outage, buying Marlowe true operational availability.
