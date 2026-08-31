## Framework Declaration
PASTA (Process for Attack Simulation and Threat Analysis)

## Rationale
The PASTA framework is selected because it is risk-centric and inherently bridges technical threat enumeration with Sundara's high-level business goals, such as its upcoming European expansion and strategic IPO ambitions. Unlike purely technical tools, PASTA aligns corporate risk thresholds with compliance obligations across multiple jurisdictions, specifically managing the friction between Singapore's PDPA and the European Union's GDPR. By mapping cross-border data flows from the 12 million active loyalty accounts, PASTA provides the exact threat-to-business alignment needed to inform board-level risk acceptance.

## Framework Selection Feedback
A distinct Sundara-specific strength of PASTA is its Stage 1 and Stage 2 focus on business impact and data scoping, allowing the organization to dissect the cross-jurisdictional liabilities of hosting Asian user data while targeting EU citizens. However, a major limitation of PASTA is its high procedural overhead, requiring extensive cross-departmental documentation which can slow down rapid technical analysis during an aggressive, time-sensitive market expansion.

## Threat Model
### 1. Cross-Border Data Flows & Jurisdictional Boundaries (PDPA vs. GDPR)
*   **Regulatory Non-Compliance:** Unlawful transfer or replication of EU citizen loyalty and payment data back to Singapore-based core infrastructure, violating GDPR cross-border transfer mechanisms (Chapter V) and triggering maximum administrative fines.
*   **Data Breach Vulnerability:** Interception or unauthorized modification of integrated payment and cross-border reservation module data in transit, simultaneously breaching PDPA and GDPR security principles.

### 2. First-Party Loyalty Application Platform (Cloud Infrastructure)
*   **Targeted Loyalty Data Theft:** Advanced persistent threat (APT) actors exploiting vulnerabilities within the AI recommendations or geolocation modules to exfiltrate bulk customer data (similar to the recent competitor breach), destroying corporate credibility before the IPO launch.
*   **Credential Stuffing / Account Takeover:** Automated attacks targeting the 12 million active loyalty accounts to steal integrated payment tokens, causing severe reputational damage.

### 3. Third-Party Ecosystem Interfaces (Out of Scope for First-Party Modeling)
*   **API Supply Chain Compromise:** Adversaries targeting the API boundaries connecting Sundara’s applications to the third-party managed POS hardware ecosystem, pivoting into Sundara's internal cloud database environment.

## Identified Findings
1.  **Finding 1 [Priority: Critical - Tied to Board Delay Decision]:** Absence of strict data localization or localized encryption boundaries separating EU expansion user metrics from legacy Singapore infrastructure, creating an immediate, high-probability risk of catastrophic GDPR non-compliance and bulk exfiltration.
2.  **Finding 2 [Priority: High]:** Lack of continuous API behavior monitoring and rate limiting on the integrated payment and reservation modules, rendering the core loyalty application vulnerable to the same automated skimming tactics that compromised the peer Asian retail competitor.
3.  **Finding 3 [Priority: High]:** Incomplete third-party risk management (TPRM) enforcement and auditing over the external vendor managing the POS hardware lifecycle, creating an unmonitored architectural blind spot at the network edge.
