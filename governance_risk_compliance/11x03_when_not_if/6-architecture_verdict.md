**To:** Copeland Foods Board of Directors  
**From:** BEHAVA Killian (Junior GRC Consultant)  
**Date:** October 12, 2026  
**Subject:** Architectural Verdict and Financial Arbitrage of ERP Resilience  

---

### 1. Maximum Tolerable Period of Disruption (MTPD) and Existential Threshold
The financial survival of Copeland is triggered immediately upon ERP (P3) failure. The cumulative financial impact accelerates across two distinct phases:
* **T+0h to T+4h:** Isolated ERP outage at €9,000/h (production P2 remains active via a manual workaround). Loss: **€36,000**.
* **From T+4h onwards:** Production (P2) stoppage, causing the combined hourly cost to surge to **€24,000/h** (€9k ERP + €15k P2).

The existential loss threshold of **€324,000** is reached after 12 hours in this second phase. The **absolute MTPD is therefore 16 hours**. In accordance with our resilience policy (50% safety margin), the **target RTO is set at 8 hours**.

### 2. Critical Failures of the Current Architecture
The current infrastructure fails both fundamental resilience equations:
* **RTO Failure (Recovery):** Restoring the 4.32 TB database at 120 MB/s requires 10 hours of transfer time and 2 hours of verification. The **actual RTO is 12 hours**, which is 4 hours beyond the safety target, accumulating **€228,000** in losses.
* **RPO Failure (Data):** Since the central directory infrastructure is compromised during a major ransomware incident, the online backup is unusable. The offline immutable copy is **26 hours old**. As EDI partners only tolerate 4 hours of order replay, the current architecture creates a **critical deficit of 22 hours of data** that must be re-keyed manually from paper.

### 3. Solution Arbitrage ("The Fix")
A technology upgrade solely targeting disk writing speed (higher throughput) can reduce transfer time to 2.5 hours (total RTO of 4.5 hours). **This cheaper alternative is rejected**: while it solves the RTO equation, it fails the RPO equation, leaving the company exposed to a 26-hour data loss that EDI partners will not accept.

**The selected architecture change** requires deploying high-performance flash storage (RTO < 8h) paired with a **4-hour immutable snapshot policy**, strictly aligning the actual RPO with EDI requirements.

### 4. Activation Mechanics
The alert and failover to the recovery architecture are declared by the Crisis Management Team under the direct authority of the Executive Management as soon as the ERP unavailability reaches **T+4h** with no immediate resolution insight, or upon detection of an active ransomware strain.

### 5. Legal Ransom Position and Stance
At T+24h, Copeland will maintain a **strict refusal to negotiate or pay the ransom**, as payment exposes the firm to sanctions related to financing restricted entities. The mandatory process requires immediate notification of the insurer before any contact with the threat actor, relying exclusively on the professional negotiator service provided in the policy rider.
