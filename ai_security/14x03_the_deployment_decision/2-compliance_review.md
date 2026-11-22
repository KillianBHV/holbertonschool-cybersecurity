# Compliance Review: Assist Billing Expansion

**Reviewer:** Nadia (Governance & AI Risk Analysis)  
**Target Artefact:** `06-compliance-self-assessment.md` (Completed by Assist platform team, reviewed by product; not independently verified)  
**Cross-Checked Against:** `01-architecture.md`, `02-dataflow-diagram.md`, `03-vendor-model-card.md`, `04-dpa-excerpt.md`, `05-sample-logs.jsonl`

---

## Executive Summary

A claim-by-claim audit of `06-compliance-self-assessment.md` shows that while several controls have architectural or log backing, **one critical assertion (`C-08`) is directly disproved by both configuration and staging logs**, and **several others (`C-05`, `C-06`, `C-07`, `C-10`) are overstated or incomplete** relative to how the system actually operates.

Most importantly, **a control that exists only on paper (`C-08`) outranks every other finding in the dossier** because it creates an *illusion of safety* across downstream teams: product, leadership, and reviewers believe untrusted customer-submitted content cannot enter the retrieval index or steer the agent, so they under-invest in runtime defenses (like `F3` prompt-injection guard) and treat an active indirect prompt-injection vector as already mitigated.

---

## Claim-by-Claim Verification Table

| ID | Area | Claimed Control | Form Response | Verdict | Primary Evidence & Discrepancies |
|---|---|---|---|---|---|
| **C-01** | Governance | An accountable owner is named for Assist. | Yes | **Supported (with caveat)** | `01-architecture.md` names **Assist platform team** as owner and `06-compliance-self-assessment.md` is signed by the **Assist platform lead**. However, `01-architecture.md` §6 shows product team constraints (`8 weeks`, `12 eng-weeks`, no-deploy excluded) constrain governance authority. |
| **C-02** | Governance | Assist changes go through peer review and release approval. | Yes | **Partially Supported (unverified in dossier)** | `01-architecture.md` header states `Status: approved for build review`. No PR/peer-review logs or release-approval records exist in the dossier, though launch is fixed at 8 weeks from sign-off. |
| **C-03** | Identity | Tool calls are scoped to the signed-in customer's identity. | Yes | **Supported** | `01-architecture.md` §3 binds each session to `customer_id` at `assist-gateway` and rejects mismatched `customer_ref` in `tool-gateway`. Confirmed in `05-sample-logs.jsonl` (`evt_000089`, `evt_000104`, `evt_000120`, `evt_000153`, `evt_000166`, `evt_000200`, `evt_000236`, `evt_000259` all log `kind: "auth_denied"`, `reason: "customer_ref_not_session_identity"`). |
| **C-04** | Data | Regulated data is encrypted in transit and at rest. | Yes | **Supported** | `01-architecture.md` §4 and `02-dataflow-diagram.md` specify TLS in transit and platform database encryption at rest. No plaintext transport or unencrypted storage evidence contradicts this. |
| **C-05** | Vendor | A data processing addendum is signed with the model provider. | Yes | **Supported with Material Caveats** | `04-dpa-excerpt.md` confirms a DPA between Larkspur Software and Tessel AI, **but** Clauses 4.2, 5.2, and 6.2 allow retention up to **365 days** for suspected abuse, training/evaluation of abuse & safety classifiers, and access by Tessel personnel and Schedule 2 sub-processors—nuancing the privacy framing in `03-vendor-model-card.md`. |
| **C-06** | Vendor | Provider sub-processors are listed and approved. | Yes | **Partially Supported** | `04-dpa-excerpt.md` Clause 6.1 references **Schedule 2** (cloud hosting provider and a contracted content-review vendor), though Schedule 2 itself is not attached in the dossier to verify specific entities or regions. |
| **C-07** | Agent | Refunds require human approval before they execute. | Yes | **Supported (operational caveats in logs)** | `01-architecture.md` §5 (`refund_approval_mode: human_required_all_amounts`) and `05-sample-logs.jsonl` show human approvals (`approval.mode: "human"`, `approver`, `decision`, `wait_ms`), e.g., `evt_000018`, `evt_000023`, `evt_000053`, `evt_000142` (`denied`). However, `05-sample-logs.jsonl` also shows out-of-order/post-approval events (e.g., `evt_000179` before `evt_000181`, `evt_000291` before `evt_000292`–`evt_000293`) and reason mismatches (`evt_000142`, `evt_000179`). |
| **C-08** | Retrieval | Content ingested into the retrieval index is source-verified. | Yes | **FALSE** | **Directly disproved** by `01-architecture.md` §5 (`ingest_source_policy: open`; `ticket_submission` indexed as received without `docs-ci` signature), `02-dataflow-diagram.md` (`ticket_submission unsigned`), and `05-sample-logs.jsonl` (`evt_000025`, `evt_000035`, `evt_000182`, `evt_000223`, `evt_000228`, `evt_000247`, `evt_000251`, `evt_000266` show `source_verified: false, signer: null`, and `evt_000242`–`evt_000243` shows `tkt-7576` triggering a `billing_lookup` tool call). |
| **C-09** | Agent | Tool inputs are schema-validated before execution. | Yes | **Supported** | `01-architecture.md` §5 (`tool_args_validation: json_schema_strict`) and `05-sample-logs.jsonl` (`validation: "schema_ok"` on valid calls; `kind: "error", code: "schema_rejected"` in `evt_000188`, `evt_000196`, `evt_000216`, `evt_000249`, `evt_000304`). |
| **C-10** | Data | Regulated fields are stripped before the model call. | Yes | **Supported for Model Call Only (No Reply Filter)** | `01-architecture.md` §5 and `02-dataflow-diagram.md` show `field-scrubber` redacts `iban`, `billing_address`, and `tax_id` before `model-adapter` sends requests to Tessel AI, matching `model_call` logs (`scrubbed: ["iban","billing_address","tax_id"]`). However, `F2` (*Reply-side filter for regulated fields*) is still listed as outstanding work in `01-architecture.md` §7. |
| **C-11** | Monitoring | Tool calls and approvals are written to an audit log. | Yes | **Supported (with ordering/completeness caveats)** | `05-sample-logs.jsonl` records `tool_call`, `tool_result`, `auth_denied`, `schema_rejected`, and `approval` objects with `event_id`, `ts`, `session_id`, and `customer_id`, though log retention/review dashboard (`F10`) is still outstanding and some event sequences appear out of chronological/causal order. |
| **C-12** | Monitoring | A regulatory classification of the billing feature has been performed. | No | **Honest "No" (Confirmed)** | `06-compliance-self-assessment.md` states *"Not yet performed,"* consistent with the dossier lacking a formal regulatory/data-protection classification for the billing expansion. |

---

## Deep Dive: The False Claim (`C-08`)

### What `C-08` Claims
Row `C-08` of `06-compliance-self-assessment.md` states:
- **Control:** *"Content ingested into the retrieval index is source-verified."*
- **Response:** `Yes`
- **Evidence cited:** *"Allowlist and `docs-ci` signing described in the ingest runbook."*

### Proof That Disproves `C-08` (Beyond "Not Found")
This is not a case where evidence is merely missing; **three independent artefacts in the dossier actively contradict `C-08`**:

1. **Staging Configuration & Architecture (`01-architecture.md` §5):**
   - The deployed configuration explicitly sets: `ingest_source_policy: open`.
   - The **Retrieval ingest** section states that `ingest-worker` indexes from `ticket_submission` (*"text and attachments customers send in via the support form"*) and explicitly adds: *"Only `kb_internal` documents are signed by `docs-ci`; `ticket_submission` documents are indexed as received."*

2. **Data-Flow Diagram (`02-dataflow-diagram.md`):**
   - The diagram explicitly labels the ingestion path as: `ingest-worker <-- kb_internal, policy_repo, ticket_submission (ticket_submission unsigned)`.

3. **Empirical Staging Logs (`05-sample-logs.jsonl`):**
   - Multiple `ingest` events prove unverified, unsigned tickets are indexed:
     - `evt_000025`: `{"ts":"2026-04-16T09:03:25Z","kind":"ingest","doc_id":"tkt-7590","origin":"ticket_submission","source_verified":false,"signer":null}`
     - `evt_000035`: `{"ts":"2026-04-16T09:53:56Z","kind":"ingest","doc_id":"tkt-2498","origin":"ticket_submission","source_verified":false,"signer":null}`
     - Also `evt_000182` (`tkt-7951`), `evt_000223` (`tkt-5196`), `evt_000228` (`tkt-1194`), `evt_000247` (`tkt-1670`), `evt_000251` (`tkt-4393`), and `evt_000266` (`tkt-2680`)—every single `ticket_submission` ingest event has `"source_verified":false` and `"signer":null`.
   - Worse, **retrieved unverified ticket content actively drove a tool call** in session `ses_532fc830`:
     - `evt_000241`: User asks *"Why was I charged twice this month?"*
     - `evt_000242`: `tool_call` for `billing_lookup` with `"context_origin":"retrieved:ticket_submission","triggered_by_doc":"tkt-7576"`
     - `evt_000243`: `retrieval` returns `{"doc_id":"tkt-7576","origin":"ticket_submission","source_verified":false}` alongside `kb-0354`.

---

## Belief vs. Reality: What `C-08` Distorts

### What the Organisation Currently Believes About Itself
Because `C-08` is marked `Yes` with a citation to *"Allowlist and `docs-ci` signing"*, leadership, product, and compliance reviewers are led to believe:
- Every document in Assist's retrieval index comes from a vetted, signed source (`docs-ci`).
- Customer-submitted support tickets (`ticket_submission`) are either excluded or sanitized/verified before entering retrieval.
- Retrieval context is a **trusted** knowledge boundary, so malicious instructions cannot enter the model's context via RAG.

### What Is Actually True
- The retrieval index ingests **raw, unsigned customer submissions (`ticket_submission`)** under an `open` ingest policy (`source_verified: false`, `signer: null`).
- Any customer can submit text or attachments through the support form that later get retrieved into other users' sessions and **trigger tool execution** (`context_origin: "retrieved:ticket_submission"` in `evt_000242`).
- The ingest runbook's allowlist/`docs-ci` signing either applies only to a subset of sources (`kb_internal`) or is not enforced across the full ingestion pipeline in staging.

---

## Why a "Paper-Only" Control Outranks Every Other Finding

A control that exists only on paper (`C-08`) is **more dangerous than an unbuilt control or a known technical flaw** for three reasons:

1. **It Poisons Downstream Risk & Budget Decisions:** Governance and product teams allocate finite resources (here, 8 weeks and 12 engineering-weeks) based on perceived gaps. If stakeholders believe retrieval is source-verified (`C-08 = Yes`), they may deprioritize `F3` (*Prompt-injection guard layer on user and retrieved text*, 3 weeks) or fail to restrict `ingest-worker` to signed/verified sources—leaving an open indirect prompt-injection channel active in production.
2. **It Creates False Assurance During Sign-Off & Audits:** A self-assessment signed by the platform lead and reviewed by product (`06-compliance-self-assessment.md`) becomes an anchor document. Without independent verification, reviewers treat `Yes` as fact rather than an unverified assertion, masking real exposure until an incident occurs.
3. **It Breaks Defense-in-Depth Assumptions:** Other controls—such as `C-03` (session identity binding) or `C-09` (JSON schema validation)—do not stop a retrieved prompt injection from manipulating how Assist uses tools within the victim's own session (`evt_000242` executed `billing_lookup` for `cus_452edb` because of `tkt-7576`). Believing `C-08` holds blinds the organisation to how untrusted data crosses from customer tickets into live agent actions.