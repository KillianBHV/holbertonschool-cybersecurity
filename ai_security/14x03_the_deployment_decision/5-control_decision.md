# 05 - Control Decision: Assist Billing Expansion

## 1. Launch Categorisation & Budget (12 Engineering-Weeks Cap)

All proposed controls are placed into one of two launch categories: **mandatory before launch** (funded within the 12 engineering-week pre-launch budget)[cite: 1, 2] and **monitored after launch** (deferred post-launch with explicit risk acceptance and monitoring triggers)[cite: 1, 2]. No third category is used.

### Mandatory Before Launch Controls (Total: 10.5 / 12 weeks)

| Control / ID | ISO/IEC 42001 Domain / Annex A | Cost (Weeks) | Launch-Blocking Risk Justification |
|---|---|---|---|
| **F3 - Prompt-injection guard layer on user and retrieved text** (plus ingest provenance & source verification on `ticket_submission` / `ingest` pipeline)[cite: 2, 6] | Operational control / AI system use & content integrity (ISO/IEC 42001 Annex A) | 3.0[cite: 2] | Unsigned `ticket_submission` documents (e.g., `tkt-7576`) are ingested without source verification (`source_verified: false`) and can trigger tool calls (`billing_lookup`) via retrieved context, while `tessel-core-2` can be influenced by untrusted text[cite: 2, 4, 6]. |
| **F4 - Vendor addendum: zero retention and training opt-out** (reinforced with `field-scrubber` redaction/stripping of `iban`, `billing_address`, `tax_id` and data minimisation)[cite: 2, 3, 5] | Third-party / supplier relationships & data governance (ISO/IEC 42001 Annex A) | 3.0[cite: 2] | Under the current DPA excerpt, Tessel AI retains Customer Input/output for 30 days (up to 365 days if flagged) and may use flagged requests to train/evaluate abuse and safety classifiers[cite: 5]. |
| **F1 - Cross-account authorisation test of the billing tools** (verifying `customer_id` binding, strict `tool-gateway` schema validation, and human-in-the-loop refund approval)[cite: 1, 2] | Information security / access & system integrity (ISO/IEC 42001 Annex A) | 2.5[cite: 2] | Logs show repeated cross-account `billing_lookup` attempts (`customer_ref_not_session_identity`) and `schema_rejected` `issue_refund` calls; billing tools (`billing_lookup`, `issue_refund`) must be verified end-to-end before launch alongside human approval (`approval.approver`) and strict schema validation[cite: 2, 6]. |
| **F5 - Kill switch and incident runbook for Assist**[cite: 2] | Incident management & operational resilience (ISO/IEC 42001 Annex A) | 1.5[cite: 2] | Model timeouts (`model_timeout`), rate limits, or unexpected billing/refund behaviour require an immediate kill switch and documented runbook at launch[cite: 2, 6]. |
| **Regulatory classification of the billing expansion (closing C-12)**[cite: 7] | Governance, compliance & risk assessment (ISO/IEC 42001 Clause 6 / Annex A) | 0.5 | Compliance self-assessment item C-12 is currently `No` (regulatory classification not yet performed)[cite: 7]; completing this paper/governance control is mandatory before launch[cite: 1]. |

### Monitored After Launch Controls (Deferred)

| Control / ID | ISO/IEC 42001 Domain / Annex A | Cost (Weeks) | Explicit Risk Acceptance & Monitoring Triggers |
|---|---|---|---|
| **F2 - Reply-side filter for regulated fields**[cite: 2] | Data protection & output controls (ISO/IEC 42001 Annex A) | 2.0[cite: 2] | **Risk acceptance:** `field-scrubber` already strips/redacts `iban`, `billing_address`, and `tax_id` on all model context before `model-adapter` sends requests to Tessel AI (`scrubbed` confirmed in logs)[cite: 2, 3, 6]. **Monitoring trigger:** Any occurrence of `[REDACTED]` leakage patterns, unredacted regulated field indicators in outbound replies, or `field-scrubber` errors/bypasses. |
| **F6 - Notice that the customer is talking to an AI system**[cite: 2] | Transparency & user information (ISO/IEC 42001 Annex A) | 1.0[cite: 2] | **Risk acceptance:** Accepted for initial launch within the 12-week cap given existing support chat flow[cite: 2, 6]. **Monitoring trigger:** Customer complaints/tickets or regulatory/compliance findings requesting explicit AI disclosure in the billing chat UI. |
| **F7 - Staff training for support agents who approve actions**[cite: 2] | Competence & human oversight (ISO/IEC 42001 Clause 7.2 / Annex A) | 1.0[cite: 2] | **Risk acceptance:** `issue_refund` already enforces mandatory human-in-the-loop approval (`human_required_all_amounts`) with `approval.approver` logged[cite: 2, 6]. **Monitoring trigger:** High refund denial/escalation anomalies, approval latency spikes (`wait_ms`), or agent approval errors in audit logs. |
| **F8 - Per-session spend and rate cap on billing tools**[cite: 2] | Resource & abuse controls (ISO/IEC 42001 Annex A) | 1.5[cite: 2] | **Risk acceptance:** Per-session rate limiting (`per_session_rpm`) and per-refund human approval are already active[cite: 2, 6]. **Monitoring trigger:** Repeated `issue_refund` proposals within a single `session_id` or `customer_id`, or `rate_limit` spikes. |
| **F9 - Red-team regression suite in CI**[cite: 2] | Testing, assurance & continuous improvement (ISO/IEC 42001 Annex A) | 2.5[cite: 2] | **Risk acceptance:** Pre-launch F1/F3 controls and staging/log checks cover initial launch risks within budget[cite: 2]. **Monitoring trigger:** Any `suspected_injection` guard flag, `auth_denied` surge, or post-launch prompt/policy change. |
| **F10 - Log retention and a review dashboard**[cite: 2] | Monitoring, measurement & auditability (ISO/IEC 42001 Clause 9.1 / Annex A) | 2.0[cite: 2] | **Risk acceptance:** Schema v3 audit logs are already emitted by `assist-gateway` and `tool-gateway`[cite: 2, 7]. **Monitoring trigger:** Audit log ingestion gaps, missing `approval.approver` / `auth_denied` records, or weekly manual review thresholds exceeded. |

---

## 2. Alignment with ISO/IEC 42001 Domains

- **Governance, Context & Compliance (ISO/IEC 42001 Clauses 4–7):** Accountable ownership (C-01), change/release review (C-02), regulatory classification (C-12), and human approval governance[cite: 2, 7].
- **Risk Assessment & Treatment (ISO/IEC 42001 Clause 6.1):** Prioritising launch-blocking risks (cross-account access, untrusted retrieved `ticket_submission` instructions, vendor retention/training terms, and operational kill-switch readiness)[cite: 2, 5, 6] within the 12-week budget[cite: 2].
- **Operation, Data & Third-Party Controls (ISO/IEC 42001 Annex A):** Enforcing session identity binding, strict schema validation, human-in-the-loop refund approval, `field-scrubber` redaction/minimisation of regulated fields (`iban`, `billing_address`, `tax_id`), and contractual DPA controls with Tessel AI[cite: 2, 3, 5, 6].
- **Performance Evaluation & Improvement (ISO/IEC 42001 Clauses 9–10):** Post-launch monitoring triggers, audit log review (schema v3), and regression testing[cite: 2, 7].
