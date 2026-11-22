# Board Recommendation: Assist Billing Expansion

## Recommendation: Go, With Conditions

Approve the billing expansion of **Assist** to launch in **8 weeks** within the **12 engineering-week** control budget, **conditional on verifiable completion before launch of**:

- **Prompt-injection and untrusted-retrieval protection:** Customer messages and retrieved content from `ticket_submission` are screened against prompt injection before influencing model actions, and untrusted ticket sources cannot trigger `billing_lookup` or `issue_refund` without verification[cite: 2, 6].
- **Signed vendor terms:** A binding addendum with Tessel AI is executed with zero data retention and full opt-out from model and classifier training[cite: 2, 5].
- **Verified billing access and refund controls:** Cross-account authorisation tests pass so sessions remain strictly locked to `customer_id`, while every refund continues to require named human approval (`approval.approver`) and strict schema checks[cite: 2, 6, 7].
- **Operational kill switch and runbook:** Engineering demonstrates a tested kill switch and incident runbook capable of disabling Assist billing actions immediately[cite: 2].
- **Completed regulatory classification:** Legal and compliance sign off on the regulatory classification of the billing expansion prior to launch[cite: 7].

## What Is Being Watched and Reconsideration Triggers

Post-launch monitoring tracks `auth_denied` events, `schema_rejected` calls, `suspected_injection` flags, `model_timeout` errors, `rate_limit` events, refund approval decisions and wait times, and `field-scrubber` redaction counts (`iban`, `billing_address`, `tax_id`)[cite: 2, 3, 6].

The board should **reconsider or pause** the rollout if any of these occur:

- Any confirmed cross-account billing data exposure or `customer_id` binding bypass[cite: 2, 6].
- A tool call or refund triggered by unverified or injected retrieved content[cite: 2, 6].
- Any `iban`, `billing_address`, or `tax_id` reaching the model provider or appearing in unredacted customer replies[cite: 2, 3, 6].
- Any refund executed without a recorded human approver or beyond approved limits[cite: 2, 6].
- Repeated `model_timeout` spikes or unresolved vendor/compliance violations[cite: 5, 6, 7].

## Compliance Gap

The self-assessment cites source-verified ingestion via allowlist and `docs-ci` signing, yet staging configuration and logs show `ingest_source_policy: open` and unsigned `ticket_submission` items (such as `tkt-7576`) entering retrieval and triggering `billing_lookup`[cite: 2, 6, 7]. Additionally, regulatory classification remains uncompleted (`No`)[cite: 7].

## Residual Risk

Larkspur accepts the residual risk that a clever prompt injection or unverified retrieved ticket could still steer `tessel-core-2` to propose invalid or policy-violating billing actions—such as a disputed refund or a flagged request retained under Tessel AI's abuse-review terms—costing engineering remediation, customer support or credit write-offs, and regulatory or reputational scrutiny[cite: 2, 4, 5, 6, 7, 8].
