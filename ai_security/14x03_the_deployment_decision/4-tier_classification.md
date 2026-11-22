# Regulatory Risk Classification & Temporal Applicability: Assist Billing Expansion

**System Assessed:** Assist — Customer Support Agent (Billing & Payments Expansion)

**Assessment Date:** 22 November 2026

**Governing Legal Framework:** Regulation (EU) 2024/1689 (EU AI Act, 13 June 2024), as amended by **Regulation (EU) 2026/1744 of 8 July 2026 ("Digital Omnibus on AI")**, published in the Official Journal of the European Union on **24 July 2026** and in force since **27 July 2026**.

**Compliance Self-Assessment Reference:** Closes gap `C-12` (*"A regulatory classification of the billing feature has been performed: No"* in `06-compliance-self-assessment.md`).

## 1. Risk Tier Classification

### Primary Classification: **Limited-Risk AI System (Specific Transparency Risk — Article 50)**

Under the EU AI Act's four-tier risk pyramid (**Unacceptable / Prohibited Risk**, **High Risk**, **Limited / Specific Transparency Risk**, and **Minimal Risk**), the billing-expanded `Assist` feature is classified as a **Limited-Risk AI system subject to specific transparency obligations under Article 50(1) and Article 50(2)** of Regulation (EU) 2024/1689.

* **Why Article 50(1) applies:** `Assist` is an AI system intended to interact directly with natural persons (customers via the `chat` channel in `05-sample-logs.jsonl`) in a bidirectional conversational exchange regarding their invoices, payment methods, and refund requests (`01-architecture.md` §1). Unless it is obvious from the circumstances and context of use that the user is interacting with an AI system, Larkspur (as provider/deployer of the customer-facing chatbot) must ensure natural persons are informed that they are interacting with an AI system. Notably, Control `F6` (*"Notice that the customer is talking to an AI system"*, 1 eng-week in `01-architecture.md` §7) is currently **unbuilt**, meaning `Assist` lacks an explicit disclosure mechanism today.

* **Why Article 50(2) applies (with nuance):** `Assist` uses `tessel-core-2` to generate synthetic natural-language replies (`kind: "reply"`). Under Article 50(2) and the European Commission's *Guidelines on the implementation of the transparency obligations for certain AI systems under Article 50* (**C(2026) 5054 final**, adopted **20 July 2026**), providers of AI systems generating synthetic text must ensure outputs are marked in a machine-readable format and detectable as artificially generated or manipulated, subject to narrow exemptions (such as purely assistive editing or short standard sequences that do not substantially alter user-supplied input).

* **Extraterritorial Nexus (Article 2(1)):** Because `Assist` processes EU-formatted payment identifiers (`iban`, `tax_id` in `01-architecture.md` §4) and serves customers whose output is used in the Union, the EU AI Act applies regardless of where Larkspur or Tessel AI is established.

## 2. Defense Against Adjacent Tiers

### A. Why `Assist` Is **NOT High-Risk** (Defense Against the Tier Above — Article 6 & Annexes I / III)

A superficial reading of *"billing, payments, and refunds"* might tempt an analyst to classify `Assist` as High-Risk under Annex III Point 5 (*Access to and enjoyment of essential private services and essential public services and benefits*). That classification is legally incorrect for four concrete reasons grounded in the system's architecture (`01-architecture.md` §§1–5):

1. **No Creditworthiness Evaluation or Credit Scoring (Annex III, Point 5(b)):** Annex III Point 5(b) captures AI systems intended to evaluate the creditworthiness of natural persons or establish their credit score. `Assist` performs **zero** credit scoring, underwriting, lending eligibility assessment, or financial profiling; it merely retrieves historical `invoices`, `payment_methods`, and `orders` (`billing_lookup`, `order_lookup`) and explains existing charges.

2. **No Life or Health Insurance Risk Assessment or Pricing (Annex III, Point 5(c)):** `Assist` is a SaaS customer-support agent handling subscription seats, plan changes, and duplicate-charge refunds (`05-sample-logs.jsonl`), not an insurance risk-pricing engine.

3. **Not a Safety Component of a Regulated Product (Article 6(1) & Annex I):** `Assist` is standalone customer-support software, not embedded as a safety component in any product covered by Union harmonisation legislation listed in Annex I.

4. **No Autonomous Financial Execution (Human-in-the-Loop Gate):** Even on `issue_refund` (which credits `customer_balance`), `01-architecture.md` §5 enforces `refund_approval_mode: human_required_all_amounts`. Every refund call is queued as `pending_approval` and cannot execute without an explicit human support agent decision (`approval.mode: "human"`, `approval.approver` in `05-sample-logs.jsonl`). Even if an expansive reading of Annex III were ever argued, `Assist` neither makes autonomous eligibility decisions nor profiles natural persons (Article 6(3)).

*(Note: While `Assist` handles regulated financial/personal fields—`iban`, `billing_address`, `tax_id`—those trigger **GDPR** obligations [Articles 5, 6, 28, 32, 44] and security controls, **not** AI Act Annex III High-Risk status.)*

### B. Why `Assist` Is **NOT Minimal-Risk** (Defense Against the Tier Below — Unregulated / Code-of-Conduct Only)

Classifying `Assist` as Minimal-Risk (zero mandatory AI Act system-level obligations) is equally indefensible:

1. **Direct Human-Facing Conversational Interface (Article 50(1)):** Minimal-risk systems include internal spam filters, inventory optimizers, or backend analytics that do not directly converse with end-users. By contrast, `Assist` conducts multi-turn natural-language dialogues directly with customers (`channel: "chat"`), creating a clear risk of anthropomorphic deception or mistaken belief that the customer is chatting with a human billing specialist—especially when `Assist` discusses refunds and invoices.

2. **Missing "Obviousness" Exemption:** Because customers contact support to resolve billing disputes and receive human-approved refunds, a reasonable user cannot infer from context alone that they are interacting with an automated LLM agent rather than a human agent—particularly while `F6` (AI disclosure notice) remains unbuilt.

3. **General-Purpose AI (GPAI) Downstream Integration:** `Assist` builds upon `tessel-core-2`, a general-purpose language model (`03-vendor-model-card.md`), bringing downstream transparency and AI literacy duties into active scope.

## 3. Applicable Obligations Today vs. Scheduled vs. Postponed (Post-Digital Omnibus Verification)

**Critical Legal Verification (as of 22 November 2026):** Regulation (EU) 2024/1689 was formally amended by **Regulation (EU) 2026/1744 (the "Digital Omnibus on AI")**, adopted on **8 July 2026**, published in the Official Journal on **24 July 2026**, and in force since **27 July 2026** (confirmed by the European Commission's *AI Act Service Desk Implementation Timeline*). Citing the original unamended 2 August 2026 high-risk deadline as live would be legally erroneous.

### Summary Matrix of Regulatory Status (As of 22 November 2026)

| Status Category | Provision / Obligation | Original Date (Reg. 2024/1689) | Current Legal Date (Post-Reg. 2026/1744) | Primary Source & Legal Effect on `Assist` | 
| ----- | ----- | ----- | ----- | ----- | 
| **LIVE TODAY** *(In force & enforceable now)* | **Prohibited AI Practices** (Art. 5(1)(a)–(h)) | 2 February 2025 | **2 February 2025** *(Unchanged)* | Reg. (EU) 2024/1689 Art. 113(a). **Live.** `Assist` must not use manipulative/deceptive techniques or exploit vulnerabilities in billing disputes. | 
| **LIVE TODAY** *(In force & enforceable now)* | **AI Literacy Duty** (Art. 4, as reworded) | 2 February 2025 | **2 February 2025** *(Reworded 27 July 2026)* | Reg. (EU) 2024/1689 Art. 4 & Reg. (EU) 2026/1744 (in force 27 July 2026). **Live.** Larkspur must promote sufficient AI literacy among staff—specifically support agents approving `issue_refund` (`F7`, 1 eng-week). | 
| **LIVE TODAY** *(In force & enforceable now)* | **GPAI Model Rules & Governance/Penalties** (Chapter V & Ch. XII) | 2 August 2025 | **2 August 2025** *(Unchanged)* | Reg. (EU) 2024/1689 Art. 113(b). **Live.** Applies to Tessel AI (`tessel-core-2`) as upstream GPAI provider; national competent authorities & penalties are active. | 
| **LIVE TODAY** *(In force & enforceable now)* | **Transparency Obligations — Chatbot Disclosure & New Generative Marking** (Art. 50(1) & Art. 50(2) for newly placed systems) | 2 August 2026 | **2 August 2026** *(Unchanged)* | Reg. (EU) 2024/1689 Art. 113; Commission Guidelines **C(2026) 5054 final** (20 July 2026). **Live.** Because the billing expansion launches *after* 2 August 2026 (8 weeks from sign-off), **Art. 50(1) user notice (`F6`) and Art. 50(2) output marking apply from Day 1 of launch.** | 
| **SCHEDULED** *(Imminent — 10 days away)* | **New Prohibitions (CSAM / Non-Consensual Intimate Deepfakes) & End of Art. 50(2) Transitional Grace Period** (Art. 5(1a) & Art. 111(4)) | N/A (New) / 2 August 2026 | **2 December 2026** *(Scheduled)* | Reg. (EU) 2026/1744 (OJ 24 July 2026), new Art. 5(1a) & Art. 111(4). **Scheduled.** The 2 Dec 2026 marking grace period applies *only* to generative systems placed on the market *before* 2 Aug 2026; `Assist`'s new billing release cannot rely on it. | 
| **POSTPONED** *(Deferred by Digital Omnibus)* | **High-Risk AI Rules — Annex III Systems** (Chapter III, Arts. 8–27, 43, 49) | ~~2 August 2026~~ | **2 December 2027** *(Postponed by 16 months)* | Reg. (EU) 2026/1744 (8 July 2026, in force 27 July 2026). **Postponed.** Would not apply to `Assist` anyway (not Annex III), and is legally deferred until 2 December 2027. | 
| **POSTPONED** *(Deferred by Digital Omnibus)* | **High-Risk AI Rules — Annex I Regulated Products** (Art. 6(1)) | ~~2 August 2027~~ | **2 August 2028** *(Postponed by 12 months)* | Reg. (EU) 2026/1744 (8 July 2026, in force 27 July 2026). **Postponed.** Inapplicable to `Assist` and deferred until 2 August 2028. | 

### Concrete Operational Consequences for Larkspur's Launch (Next 8 Weeks)

1. **Immediate Mandatory Launch Blocker (`F6` — Article 50(1)):** Because Article 50 entered into application on **2 August 2026** and was **not** postponed by Regulation (EU) 2026/1744, shipping the billing expansion without a clear, upfront notice that the customer is interacting with an AI system (`F6`, 1 engineering-week) is a **live statutory violation** on launch day, carrying administrative fines of up to **EUR 15 million or 3% of total worldwide annual turnover** (Article 99(4)).

2. **Immediate Staff Literacy Requirement (`F7` — Article 4):** Article 4 has been live since **2 February 2025** (and clarified by Regulation (EU) 2026/1744 on **27 July 2026**). Support agents who review and approve `issue_refund` requests (`agt_tosei`, `agt_mpatel`, `agt_rhale`, `agt_lduarte`) must receive role-appropriate AI literacy training (`F7`, 1 engineering-week) covering `tessel-core-2`'s limitations, hallucination risks, and prompt-injection exposure.

3. **Do Not Waste Engineering Budget on Deferred High-Risk Conformity Formalities:** Because `Assist` is **not** a High-Risk system—and even Annex III High-Risk obligations have been **postponed to 2 December 2027** under Regulation (EU) 2026/1744—Larkspur must not misallocate its scarce **12 engineering-weeks** toward Annex III conformity assessments, EU database registration (Article 49), or Fundamental Rights Impact Assessments (Article 27), and instead fund `F6` (1w) and `F7` (1w) alongside critical security controls.

## Primary Sources Cited

* **Regulation (EU) 2024/1689** of the European Parliament and of the Council of **13 June 2024** laying down harmonised rules on artificial intelligence (Artificial Intelligence Act), OJ L 2024/1689, **12 July 2024** (Articles 2, 4, 5, 6, 50, 99, 113; Annexes I and III).

* **Regulation (EU) 2026/1744** of the European Parliament and of the Council of **8 July 2026** amending Regulation (EU) 2024/1689 ("Digital Omnibus on AI"), published in the Official Journal of the European Union on **24 July 2026**, entered into force **27 July 2026** (amending Articles 4, 5, 111, and postponing Annex III high-risk application to **2 December 2027** and Annex I to **2 August 2028**).

* **European Commission Guidelines C(2026) 5054 final**, adopted **20 July 2026**, *Guidelines on the implementation of the transparency obligations for certain AI systems under Article 50 of Regulation (EU) 2024/1689*.

* **European Commission AI Act Service Desk**, *Timeline for the Implementation of the EU AI Act* (updated post-Regulation (EU) 2026/1744).