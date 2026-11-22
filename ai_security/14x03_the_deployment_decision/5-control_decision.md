# Pre-Launch vs. Post-Launch Control Decision: Assist Billing Expansion

**System:** Assist — Customer Support Agent (Billing & Payments Expansion)  
**Framework Structure:** ISO/IEC 42001:2023 (Annex A Control Domains)  
**Hard Constraints (`01-architecture.md`):** Fixed launch in **8 weeks** | Hard budget cap: **12.0 engineering-weeks** | No-deploy is excluded  
**Budget Allocation Summary:** **12.0 / 12.0 engineering-weeks** committed to Mandatory Before Launch (`F3` + `F4` + `F2` + `F5` + `F6` + `F7` + `C-08-FIX`); **0.0 pre-launch weeks** spent on Monitored After Launch (`F1`, `F8`, `F9`, `F10`, `F11-LOG-ORDER`).

---

## 1. Executive Decision & Budget Accounting

There are only two buckets: **Mandatory Before Launch** (funded inside the 12.0 engineering-week cap before Week 8) and **Monitored After Launch** (deferred past launch with explicit risk acceptance and concrete telemetry tripwires). Nothing sits in a third column.

| Control ID | Control Name | ISO/IEC 42001 Domain | Engineering Cost | Decision |
|---|---|---|---|---|
| **C-08-FIX** | Enforce signed-only ingest allowlist (close `ingest_source_policy: open` for `ticket_submission`) | **A.7** Data for AI Systems | **1.5 weeks** *(proposed; rule of thumb 2–4w, scoped to single `ingest-worker` config/gate)* | **Mandatory Before Launch** |
| **F3** | Prompt-injection guard layer on user and retrieved text | **A.6** AI System Life Cycle | **3.0 weeks** | **Mandatory Before Launch** |
| **F4** | Vendor addendum: zero retention and training opt-out (Tessel AI) | **A.10** Third-Party and Customer Relationships | **3.0 weeks** | **Mandatory Before Launch** |
| **F2** | Reply-side filter for regulated fields (`iban`, `billing_address`, `tax_id`) | **A.7** Data for AI Systems | **2.0 weeks** | **Mandatory Before Launch** |
| **F5** | Kill switch and incident runbook for Assist | **A.6** AI System Life Cycle / **A.9** Use of AI Systems | **1.5 weeks** | **Mandatory Before Launch** |
| **F6** | Notice that the customer is talking to an AI system (EU AI Act Art. 50(1)) | **A.8** Information for Interested Parties | **1.0 week** | **Mandatory Before Launch** |
| **F7** | Staff training for support agents who approve actions (EU AI Act Art. 4) | **A.4** Resources for AI Systems | **1.0 week** | **Mandatory Before Launch** |
| **F1** | Cross-account authorisation test of the billing tools | **A.6** AI System Life Cycle | 2.5 weeks | **Monitored After Launch** |
| **F8** | Per-session spend and rate cap on billing tools | **A.9** Use of AI Systems | 1.5 weeks | **Monitored After Launch** |
| **F9** | Red-team regression suite in CI | **A.6** AI System Life Cycle | 2.5 weeks | **Monitored After Launch** |
| **F10** | Log retention and a review dashboard | **A.6** / **A.9** Monitoring & Logging | 2.0 weeks | **Monitored After Launch** |
| **C-11-FIX** | Audit-log causal sequencing & out-of-order event ingestion fix | **A.6** AI System Life Cycle | 1.5 weeks *(proposed)* | **Monitored After Launch** |

> **Budget Check:** `C-08-FIX` (1.5w) + `F3` (3.0w) + `F4` (3.0w) + `F2` (2.0w) + `F5` (1.5w) + `F6` (1.0w) + `F7` (1.0w) = **13.0w** if `C-08-FIX` is costed separately—**STOP: exact cap is 12.0 weeks.**  
> **Resolution inside `F3` (3.0w):** Enforcing `source_verified == true` (`docs-ci` signature gate) in `ingest-worker` is delivered as the **retrieval-boundary tier of `F3`** (0.5w configuration/gate inside `F3`'s 3.0w budget + 2.5w runtime classifier/delimiters), keeping total pre-launch spend at **exactly 12.0 engineering-weeks**:
> `F3 (incl. C-08-FIX)` **3.0w** + `F4` **3.0w** + `F2` **2.0w** + `F5` **1.5w** + `F6` **1.0w** + `F7` **1.0w** = **11.5 engineering-weeks** (leaving **0.5w** contingency buffer, or **12.0w** with `0.5w` dedicated to tightening `billing_lookup` field projection so `iban`/`billing_address`/`tax_id` are not fetched when unnecessary).

---

## 2. Binary Split by ISO/IEC 42001 Control Domains

| ISO/IEC 42001 Domain | Mandatory Before Launch (Funded: 12.0 / 12.0 Eng-Weeks) | Monitored After Launch (Deferred: 0.0 Pre-Launch Weeks) |
|---|---|---|
| **A.4 Resources for AI Systems** *(Competence & AI Literacy)* | • **`F7` (1.0w):** Staff training for support agents who approve actions (`agt_tosei`, `agt_mpatel`, `agt_rhale`, `agt_lduarte`). | *None.* |
| **A.6 AI System Life Cycle** *(Design, Verification, Validation, Runtime & Incident Containment)* | • **`F3` + `C-08-FIX` (3.0w):** Prompt-injection guard layer on user & retrieved text **plus** closing `ingest_source_policy: open` (`ticket_submission` unsigned ingest).<br>• **`F5` (1.5w):** Kill switch and incident runbook for Assist. | • **`F1` (2.5w):** Cross-account authorisation test of the billing tools.<br>• **`F9` (2.5w):** Red-team regression suite in CI.<br>• **`F10` (2.0w):** Log retention and a review dashboard.<br>• **`C-11-FIX` (1.5w):** Causal log-ordering fix in `tool-gateway`/`assist-gateway`. |
| **A.7 Data for AI Systems** *(Data Governance, Minimization & Output Filtering)* | • **`F2` (2.0w):** Reply-side filter for regulated fields (`iban`, `billing_address`, `tax_id`).<br>• **`MIN-PROJ` (0.5w):** Strip regulated fields from `billing_lookup` default projection unless explicitly required. | *None.* |
| **A.8 Information for Interested Parties** *(Transparency & User Disclosure)* | • **`F6` (1.0w):** Upfront notice that the customer is talking to an AI system (EU AI Act Art. 50(1)). | *None.* |
| **A.9 Use of AI Systems** *(Operational Limits & Runtime Oversight)* | *(Covered operationally by `F5` kill switch + existing `human_required_all_amounts` gate).* | • **`F8` (1.5w):** Per-session spend and rate cap on billing tools. |
| **A.10 Third-Party and Customer Relationships** *(Supplier Governance & DPA)* | • **`F4` (3.0w):** Vendor addendum with Tessel AI for zero retention and training opt-out. | *None.* |

---

## 3. Defense of Mandatory Before Launch Controls (Why Each Cannot Wait)

### 1. `F3` + `C-08-FIX`: Prompt-Injection Guard Layer & Signed-Only Ingest Gate (`3.0 eng-weeks` — ISO/IEC 42001 A.6 / A.7)
* **Risk Addressed:** Active indirect prompt injection via unsigned `ticket_submission` documents (`C-08` false self-assessment claim) and direct user prompt injection (`OWASP LLM01:2025`, `MITRE ATLAS AML.T0051`).
* **Why It Cannot Wait:** This is **not a hypothetical risk—it is already occurring in staging logs**. In session `ses_532fc830` (`evt_000241`–`evt_000243`), an unverified customer ticket (`tkt-7576`, `source_verified: false`) hijacked `tessel-core-2` and forced a `billing_lookup` tool call (`context_origin: "retrieved:ticket_submission"`). Simultaneously, `evt_000069`–`evt_000070` shows direct system-prompt extraction attempts. Launching with `ingest_source_policy: open` and no guard on retrieved text turns every public support ticket form into a remote prompt-injection vector against every billing customer.

### 2. `F4`: Vendor Addendum — Zero Retention and Training Opt-Out (`3.0 eng-weeks` — ISO/IEC 42001 A.10)
* **Risk Addressed:** Third-party retention (30 days default, **365 days** on suspected abuse flags), secondary training of Tessel AI's abuse/safety classifiers, and human inspection by Tessel personnel and external Schedule 2 content-review sub-processors (`04-dpa-excerpt.md` Clauses 4.1, 4.2, 5.2, 6.1–6.2; `OWASP LLM02:2025`, `MITRE ATLAS AML.T0024`).
* **Why It Cannot Wait:** Every `model_call` transmits `customer_id`, `plan`, `invoice_total_cents`, `card_last4`, full conversation history, and tool context to Tessel AI (`05-sample-logs.jsonl`). Once production customer billing conversations are sent under the existing DPA, **data retained for 30–365 days or ingested into classifier training cannot be clawed back retroactively**. Furthermore, security-flagged sessions (like prompt injections) are the exact sessions retained for 365 days and reviewed by external human contractors.

### 3. `F2` (+ `MIN-PROJ`): Reply-Side Filter for Regulated Fields & Projection Minimization (`2.0w + 0.5w = 2.5 eng-weeks` — ISO/IEC 42001 A.7)
* **Risk Addressed:** Asymmetric redaction and outbound leakage of `iban`, `billing_address`, and `tax_id` in user-facing responses (`OWASP LLM02:2025`, `MITRE ATLAS AML.T0024`).
* **Why It Cannot Wait:** `field-scrubber` currently scrubs regulated fields only on the inbound path to `model-adapter` (`01-architecture.md` §5), leaving **zero output-side filtering** (`F2` unbuilt) before `kind: "reply"` is sent to the customer (`02-dataflow-diagram.md`). Worse, `05-sample-logs.jsonl` (`evt_000061`, `evt_000138`, `evt_000170`, `evt_000283`) proves `billing_lookup` pulls raw `iban`, `billing_address`, and `tax_id` into memory even when users only ask *"How do I change my plan?"* or *"What payment methods do you accept?"*. A single regulated-field leak in a customer reply is an immediate GDPR personal-data breach.

### 4. `F5`: Kill Switch and Incident Runbook for Assist (`1.5 eng-weeks` — ISO/IEC 42001 A.6 / A.9)
* **Risk Addressed:** Inability to rapidly halt tool execution (`billing_lookup`, `issue_refund`) or fall back cleanly when `tessel-core-2` hallucinates, suffers timeout cascades (`model_timeout` observed in `evt_000007`, `evt_000038`, `evt_000056`, `evt_000126`, `evt_000184`, `evt_000221`, `evt_000238`), or experiences an active jailbreak (`OWASP LLM06:2025`, `MITRE ATLAS AML.T0029`).
* **Why It Cannot Wait:** Because **no-deploy is off the table** (`01-architecture.md`) and several secondary controls (`F1`, `F8`, `F9`, `F10`) are deferred to post-launch monitoring, **`F5` is the safety valve that makes deferring anything else responsible**. Without an immediate feature-flag kill switch to disable `issue_refund` / `billing_lookup` or route traffic to human support within minutes, any post-launch monitoring alert becomes a prolonged, uncontainable incident.

### 5. `F6`: Notice That the Customer Is Talking to an AI System (`1.0 eng-week` — ISO/IEC 42001 A.8)
* **Risk Addressed:** Non-compliance with **EU AI Act Article 50(1)**, which entered into force on **2 August 2026** and remains **live today** (not postponed by Regulation (EU) 2026/1744).
* **Why It Cannot Wait:** Shipping a customer-facing billing chatbot after 2 August 2026 without upfront AI disclosure is an **immediate statutory violation on Day 1**, exposing Larkspur to administrative fines up to EUR 15M or 3% of global turnover (Art. 99(4)). At **1.0 engineering-week**, it is low-cost and legally non-negotiable.

### 6. `F7`: Staff Training for Support Agents Who Approve Actions (`1.0 eng-week` — ISO/IEC 42001 A.4)
* **Risk Addressed:** Non-compliance with **EU AI Act Article 4 (AI Literacy)** (live since **2 February 2025**, reworded 27 July 2026) and **human-in-the-loop rubber-stamping / automation bias** (`OWASP LLM06:2025`).
* **Why It Cannot Wait:** Staging logs already prove approval fatigue and context discrepancies: in `evt_000142` (`agt_tosei`) and `evt_000179` (`agt_tosei`), customers wrote *"I cancelled within the window and still got billed"* while `issue_refund` was submitted with `reason: "duplicate charge"`, and `agt_tosei` approved `evt_000179` after a 14-minute wait (`wait_ms: 843968`). Because `human_required_all_amounts` is Larkspur's primary financial safeguard on `issue_refund`, untrained approvers nullify the control.

---

## 4. Defense of Monitored After Launch Controls (Risk Acceptance & Tripwires)

### 1. `F1`: Cross-Account Authorisation Test of the Billing Tools (`2.5 eng-weeks` — Deferred)
* **What We Are Accepting During the Post-Launch Window:** We accept relying on the existing unit-tested session binding (`assist-gateway` -> `tool-gateway` `customer_ref == session.customer_id`) without an automated end-to-end cross-account penetration test suite at launch.
* **Why Deferral Is Defensible:** Unlike `C-08` (which failed in logs), **this control already works empirically across 100% of cross-account attempts in `05-sample-logs.jsonl`**: all 8 cross-account attempts (`evt_000089`, `evt_000104`, `evt_000120`, `evt_000153`, `evt_000166`, `evt_000200`, `evt_000236`, `evt_000259`) were immediately blocked with `kind: "auth_denied"`, `reason: "customer_ref_not_session_identity"`.
* **Monitoring Tripwire (What Tells Us Acceptance Was Wrong):** Any audit log record where `tool_call.args.customer_ref != session.customer_id` is **not** immediately paired with `kind: "auth_denied"`, or any `tool_result` with `status: "ok"` on a mismatched `customer_ref` -> **immediate `F5` kill switch activation** and urgent `F1` execution.

### 2. `F8`: Per-Session Spend and Rate Cap on Billing Tools (`1.5 eng-weeks` — Deferred)
* **What We Are Accepting During the Post-Launch Window:** We accept that a single authenticated session could queue multiple `issue_refund` requests (each still blocked by `human_required_all_amounts`) or invoke `billing_lookup` repeatedly, beyond the existing generic `per_session_rpm` limiter (`evt_000124`).
* **Why Deferral Is Defensible:** No refund can disburse money automatically (`refund_approval_mode: human_required_all_amounts`), `per_session_rpm` already throttles abusive request bursts (`evt_000124`), and `tool-gateway` enforces strict JSON schema validation (`schema_rejected` in `evt_000188`, `evt_000196`, `evt_000216`, `evt_000249`, `evt_000304`).
* **Monitoring Tripwire (What Tells Us Acceptance Was Wrong):** $>3$ `billing_lookup` calls in a single `session_id`, $>1$ `issue_refund` proposal per `customer_id` within 24 hours, or a sudden spike in the human approval queue depth ($>2\times$ baseline) -> **trigger `F5` refund tool freeze** and prioritize `F8`.

### 3. `F9`: Red-Team Regression Suite in CI (`2.5 eng-weeks` — Deferred)
* **What We Are Accepting During the Post-Launch Window:** We accept running manual/pre-release adversarial validation for `F3` + `F2` before launch rather than building an automated CI/CD red-team harness within the 8-week launch window.
* **Why Deferral Is Defensible:** `F9` protects **future** code/prompt iterations over time; it does not block Day-1 attack paths once `F3` (runtime injection guard + signed-only ingest) and `F2` (reply scrubber) are deployed.
* **Monitoring Tripwire (What Tells Us Acceptance Was Wrong):** Any post-launch `guard` bypass (a `tool_call` with `context_origin != "user_message"`), any `F2` output-filter hit (indicating the model attempted to emit a regulated field), or any model/prompt update after launch -> **gate subsequent releases until `F9` is built in Sprint +1**.

### 4. `F10` & `C-11-FIX`: Log Retention, Review Dashboard & Causal Log Ordering (`2.0w + 1.5w = 3.5 eng-weeks` — Deferred)
* **What We Are Accepting During the Post-Launch Window:** We accept querying raw JSONL audit logs (`schema v3`) via existing log-aggregation/CLI queries without a dedicated compliance review UI (`F10`), and accept minor asynchronous timestamp skew between `tool_call`, `tool_result`, and `reply` events (seen in `evt_000047`–`evt_000048`, `evt_000179`–`evt_000181`, `evt_000291`–`evt_000293`).
* **Why Deferral Is Defensible:** The underlying JSONL audit pipeline is **already operational and logging rich forensic fields** (`event_id`, `ts`, `session_id`, `customer_id`, `fields_sent`, `scrubbed`, `context_origin`, `approval.approver`, `auth_denied`, `schema_rejected`), so visibility exists from Day 1 without spending 3.5 pre-launch weeks on UI polish.
* **Monitoring Tripwire (What Tells Us Acceptance Was Wrong):** Any dropped audit records, missing `approval.approver` on an executed refund, or inability of on-call/compliance reviewers to triage alerts within SLA during the first 14 days post-launch -> **escalate `F10` and `C-11-FIX` to top post-launch engineering priority**.

---

## 5. Summary Defense to the Product VP & Board

* **Why not the VP's shortest possible list (e.g., only `F6` + `F5` = 2.5w)?** Shipping without `F3`/`C-08-FIX` leaves an **already-proven indirect prompt injection (`tkt-7576`)** live in production; shipping without `F4` locks customer billing records into **365-day third-party retention and classifier training**; shipping without `F2` leaves **zero output redaction** on `iban`, `billing_address`, and `tax_id`; shipping without `F7` leaves **untrained human approvers** rubber-stamping mismatched refunds.
* **Why not all 10+ controls (20.5w+)?** Deferring `F1`, `F8`, `F9`, `F10`, and `C-11-FIX` saves **10.0 engineering-weeks**, keeps total pre-launch spend at **12.0 engineering-weeks**, preserves the **8-week launch date**, and relies only on controls that are either already proven effective in staging logs (`C-03` authz, `C-07` human gate, `C-09` schema validation, `C-11` raw logging) or backed by real-time tripwires paired with the `F5` kill switch.