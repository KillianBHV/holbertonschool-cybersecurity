# AI Risk Register: Assist Billing Expansion

**System:** Assist (Customer Support Agent — Billing & Payments Expansion)[cite: 2]  
**Owner:** Assist Platform Team (Larkspur Software)[cite: 2]  
**Model Provider:** Tessel AI (`tessel-core-2`)[cite: 2, 4]  
**Framework Structure:** NIST AI Risk Management Framework (AI RMF 1.0)[cite: 9]  
**Taxonomies:** OWASP Top 10 for LLM Applications (2025) & MITRE ATLAS[cite: 9]  
**Programme Constraints:** Fixed launch in 8 weeks | Total control budget: 12 engineering-weeks (No-deploy is excluded)[cite: 2]

---

## What Assist Actually Does with Regulated Data (Empirical Reality vs. Design Intent)

Cross-referencing `01-architecture.md`, `02-dataflow-diagram.md`, `03-vendor-model-card.md`, `04-dpa-excerpt.md`, `05-sample-logs.jsonl`, and `06-compliance-self-assessment.md` shows a clear gap between stated intent and actual runtime behaviour[cite: 2, 3, 4, 5, 6, 7, 9]:

1. **Regulated vs. ordinary data split (`01-architecture.md`, `02-dataflow-diagram.md`):** Regulated fields are `iban`, `billing_address`, and `tax_id`[cite: 2, 3]. Ordinary fields are `customer_id`, `plan`, `invoice_total_cents`, and `card_last4`[cite: 2, 3]. Data in transit uses TLS and data at rest is encrypted by the platform database[cite: 2].
2. **Actual tool retrieval vs. query intent (`05-sample-logs.jsonl`):** When `billing_lookup` runs, `tool_result` returns `invoice_id`, `invoice_total_cents`, `card_last4`, `iban`, `billing_address`, and `tax_id` (`evt_000002`, `evt_000048`, `evt_000061`, `evt_000075`, `evt_000094`, `evt_000099`, `evt_000138`, `evt_000146`, `evt_000158`, `evt_000162`, `evt_000170`, `evt_000205`, `evt_000244`, `evt_000273`, `evt_000283`, `evt_000312`)[cite: 6]. In logs, `billing_lookup` also triggers on sessions where the user asks *"How do I change my plan?"* (`ses_a59416ce`, `ses_1f2b354a`, `ses_867c753f`, `ses_a6a7c3f3`) or *"What payment methods do you accept?"* (`ses_3ba90cbd`, `ses_67b2e357`, `ses_e2f314c0`)[cite: 6].
3. **Scrubbing before model dispatch, no reply-side filter (`02-dataflow-diagram.md`, `05-sample-logs.jsonl`):** `field-scrubber` runs on all context assembled for the model (`regulated_field_scrubber_scope: all_model_context`), so `model_call` logs show `fields_sent: ["customer_id","plan","invoice_total_cents","card_last4"]` and `scrubbed: ["iban","billing_address","tax_id"]`[cite: 2, 3, 6]. However, no reply-side filter (`F2`) exists before sending the response to the customer[cite: 2, 3].
4. **Vendor retention and human review beyond model card claims (`03-vendor-model-card.md`, `04-dpa-excerpt.md`):** While `03-vendor-model-card.md` states inputs are not used to train foundation models[cite: 4], `04-dpa-excerpt.md` Clauses 4.1–6.2 retain Customer Input and output for 30 days by default, up to 365 days if flagged for suspected abuse, allow access by authorised Provider reviewers and a contracted content-review vendor, and allow training or evaluating abuse and safety classifiers on flagged requests[cite: 5].
5. **Ingestion & self-assessment mismatch (`01-architecture.md`, `05-sample-logs.jsonl`, `06-compliance-self-assessment.md`):** `C-08` claims source-verified ingestion with allowlist and `docs-ci` signing, yet `ingest_source_policy` is `open` and unsigned `ticket_submission` items (`source_verified: false`, `signer: null`) are ingested into the retrieval index (`evt_000025`, `evt_000035`, `evt_000182`, `evt_000223`, `evt_000228`, `evt_000247`, `evt_000251`, `evt_000266`) and can trigger `billing_lookup` (`ses_532fc830`, `evt_000242`–`evt_000243`, via `tkt-7576`)[cite: 2, 6, 7].

---

## 1. GOVERN

| Risk ID | Risk Title & Empirical Evidence | OWASP LLM | MITRE ATLAS | Severity | Mitigation / Control Reference |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **RSK-GOV-01** | **Missing Regulatory Classification Before Fixed Launch**<br>**Evidence:** `06-compliance-self-assessment.md` marks `C-12` (*A regulatory classification of the billing feature has been performed*) as `No`, while `01-architecture.md` sets an 8-week launch date and 12 engineering-week budget with no no-deploy option[cite: 2, 7]. | **LLM06:2025** Excessive Agency | **No direct MITRE ATLAS attack technique applies** *(Governance / compliance control gap; NIST AI RMF GOVERN)*[cite: 11] | **High** | Complete regulatory classification prior to launch sign-off (`C-12` remediation)[cite: 7]. |
| **RSK-GOV-02** | **Self-Assessment Overstates Source Verification on Retrieval Ingest**<br>**Evidence:** `06-compliance-self-assessment.md` marks `C-08` as `Yes` (`docs-ci` signing), whereas `01-architecture.md` (`ingest_source_policy: open`) and `05-sample-logs.jsonl` (`evt_000025`, `evt_000247`, `evt_000266`) show unsigned `ticket_submission` items (`source_verified: false`, `signer: null`) entering the index[cite: 2, 6, 7]. | **LLM04:2025** Data and Model Poisoning | **AML.T0020** Poison Training Data *(RAG corpus / `ingest-worker`)* | **High** | Enforce source verification / signing on `ingest-worker` and close `C-08` gap[cite: 2, 7]. |
| **RSK-GOV-03** | **Vendor 365-Day Retention, Human Review & Classifier Training Exposure**<br>**Evidence:** `04-dpa-excerpt.md` Clauses 4.1–6.2 retain Customer Input/output for 30 days (up to 365 days when flagged for suspected abuse), permit access by Provider reviewers and a contracted content-review vendor, and allow training abuse/safety classifiers on flagged requests, contrasting with `03-vendor-model-card.md`[cite: 4, 5]. | **LLM02:2025** Sensitive Information Disclosure | **No direct MITRE ATLAS attack technique applies** *(Third-party retention & contractual control gap; `F4` / NIST AI RMF GOVERN)*[cite: 5, 11] | **High** | Execute vendor addendum `F4` (zero retention and training/review opt-out)[cite: 2, 5]. |

---

## 2. MAP

| Risk ID | Risk Title & Empirical Evidence | OWASP LLM | MITRE ATLAS | Severity | Mitigation / Control Reference |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **RSK-MAP-01** | **Indirect Prompt Injection via Unsigned `ticket_submission` Retrieval**<br>**Evidence:** `02-dataflow-diagram.md` shows `ticket_submission (unsigned)` feeding `retrieval`; in `05-sample-logs.jsonl`, session `ses_532fc830` (`evt_000241`–`evt_000243`) shows `billing_lookup` triggered with `context_origin: "retrieved:ticket_submission"` and `triggered_by_doc: "tkt-7576"` (`source_verified: false`)[cite: 3, 6]. | **LLM01:2025** Prompt Injection | **AML.T0051.001** LLM Prompt Injection: Indirect | **Critical** | Deploy prompt-injection guard layer `F3` on user and retrieved text and restrict untrusted `ticket_submission` ingestion[cite: 2, 3, 6]. |
| **RSK-MAP-02** | **Unscoped Tool Execution Returning Regulated Fields During Non-Billing Queries**<br>**Evidence:** `05-sample-logs.jsonl` shows `billing_lookup` returning `iban`, `billing_address`, and `tax_id` (`evt_000002`, `evt_000061`, `evt_000138`) even in sessions asking about plan changes (`ses_a59416ce`, `ses_1f2b354a`) or payment methods (`ses_3ba90cbd`, `ses_67b2e357`)[cite: 6]. | **LLM02:2025** Sensitive Information Disclosure | **AML.T0037** Data from Information Repositories | **High** | Minimise fields returned/fetched for `billing_lookup` and validate tool call necessity[cite: 2, 6]. |
| **RSK-MAP-03** | **Missing Reply-Side Filtering for Regulated Fields Before Customer Output**<br>**Evidence:** `02-dataflow-diagram.md` and `01-architecture.md`/§7 show `field-scrubber` operating on model context (`all_model_context`), while `F2` (*Reply-side filter for regulated fields*, 2 weeks) is unbuilt ahead of `reply to customer`[cite: 2, 3]. | **LLM02:2025** Sensitive Information Disclosure | **AML.T0057** LLM Data Leakage | **High** | Implement reply-side filter `F2` for regulated fields (`iban`, `billing_address`, `tax_id`)[cite: 2, 3]. |
| **RSK-MAP-04** | **Cross-Tenant Retrieval Leak via Shared Vector / Embedding Index of Customer Tickets**<br>**Evidence:** `01-architecture.md`/§5 and `02-dataflow-diagram.md` show `ingest-worker` indexing customer-submitted `ticket_submission` text and attachments (`evt_000025`, `evt_000035`, `evt_000243`) into a shared `retrieval` index queried across sessions without per-customer tenant isolation or provenance filtering, risking cross-customer retrieval leak through vector/embedding similarity[cite: 2, 3, 6]. | **LLM08:2025** Vector and Embedding Weaknesses *(Retrieval leak)* | **AML.T0024** Exfiltration via ML Inference API | **High** | Exclude customer `ticket_submission` data from shared vector/embedding retrieval or enforce strict tenant scoping and source verification[cite: 2, 6]. |

---

## 3. MEASURE

| Risk ID | Risk Title & Empirical Evidence | OWASP LLM | MITRE ATLAS | Severity | Mitigation / Control Reference |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **RSK-MEA-01** | **Cross-Account Authorisation Attempts & Uncompleted Billing Tool Auth Testing**<br>**Evidence:** `05-sample-logs.jsonl` records repeated `auth_denied` (`customer_ref_not_session_identity`) events when users request another account's invoice (`evt_000089`, `evt_000104`, `evt_000120`, `evt_000153`, `evt_000166`, `evt_000200`, `evt_000236`, `evt_000259`), while `F1` (*Cross-account authorisation test of the billing tools*, 2.5 weeks) remains pending[cite: 2, 6]. | **LLM06:2025** Excessive Agency | **AML.T0054** LLM Jailbreak *(Adversarial tool-invocation coercion)* | **High** | Complete cross-account authorisation testing `F1` across `billing_lookup` and `issue_refund`[cite: 2, 6]. |
| **RSK-MEA-02** | **Recurring `schema_rejected` Errors on Dollar-to-Cent Refund Conversions**<br>**Evidence:** In `05-sample-logs.jsonl`, requests saying *"Refund me 20 dollars please"* (`evt_000187`, `evt_000195`, `evt_000215`, `evt_000248`, `evt_000303`) repeatedly fail schema validation with `schema_rejected` (`amount_cents: expected integer`)[cite: 2, 6]. | **LLM05:2025** Improper Output Handling | **AML.T0043** Craft Adversarial Data | **Medium** | Tighten schema/argument handling and add regression coverage (`F9`)[cite: 2, 6]. |

---

## 4. MANAGE

| Risk ID | Risk Title & Empirical Evidence | OWASP LLM | MITRE ATLAS | Severity | Mitigation / Control Reference |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **RSK-MAN-01** | **Unbounded Per-Session Refund Volume & Reason Discrepancies Under Human Approval**<br>**Evidence:** `01-architecture.md`/§7 shows `human_required_all_amounts` is active (`evt_000018`, `evt_000023`, `evt_000053`, `evt_000142`), but `F8` (*Per-session spend and rate cap on billing tools*, 1.5 weeks) and `F7` (*Staff training for support agents who approve actions*, 1 week) are unbuilt; logs also show `evt_000177` (*"cancelled within the window"*) paired with `reason: "duplicate charge"` (`evt_000179`)[cite: 2, 6]. | **LLM06:2025** Excessive Agency | **AML.T0040** ML Model Inference API Access *(Abuse of tool/approval workflow)* | **High** | Fund and deploy per-session spend and rate cap `F8` and approver training `F7`[cite: 2, 6]. |
| **RSK-MAN-02** | **No Dedicated Kill Switch, Runbook, or Log Review Dashboard at Launch**<br>**Evidence:** `01-architecture.md` lists `F5` (*Kill switch and incident runbook for Assist*, 1.5 weeks) and `F10` (*Log retention and a review dashboard*, 2 weeks) as uncompleted while `model_timeout` (`evt_000007`, `evt_000038`, `evt_000056`, `evt_000126`, `evt_000184`, `evt_000221`, `evt_000238`) and `rate_limit` (`evt_000124`) occur in staging logs[cite: 2, 6]. | **LLM10:2025** Unbounded Consumption | **No direct MITRE ATLAS attack technique applies** *(Incident response & observability control gap; `F5` / `F10` / NIST AI RMF MANAGE)*[cite: 2, 11] | **High** | Implement kill switch and incident runbook `F5` and log retention/dashboard `F10`[cite: 2, 6]. |
