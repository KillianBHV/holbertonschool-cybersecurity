# The Scope Creep
## 1) What happened
- RedLine Security was contracted to perform a penetration test limited to the client's public e-commerce application and its associated API.
- During the assessment, a consultant accessed an internal billing service that was explicitly outside the agreed scope after discovering it was reachable through a firewall misconfiguration. He authenticated using default administrator credentials and viewed customer billing records before reporting the issue as a "bonus discovery."
- The billing system was operated by a third-party provider, resulting in allegations of unauthorized access, contractual violations, and legal consequences.

## 2) Violations
- The consultant failed to respect the agreed scope of the engagement by intentionally accessing systems that were explicitly out of scope.
- This violated fundamental professional standards governing authorization and scope compliance during penetration testing.
- Depending on the applicable jurisdiction, the access may also constitute unauthorized access to a third party's systems.
- The scenario additionally references potential PCI-DSS concerns because payment-related data was accessed without authorization.

## 3) What the correct professional behavior would have been
- The consultant should have stopped testing when the out-of-scope billing service was identified.
- The discovery should have been documented as an observation, and the client should have been informed so that authorization could be obtained before any further testing.
- If the third-party provider's systems needed to be assessed, a separate authorization and engagement involving the provider should have been established.

## 4) Pre-engagement specific clauses
- Explicit definition of in-scope and out-of-scope assets.
- Statement prohibiting testing beyond the approved scope.
- Third-party asset handling clause.
- Scope change / authorization procedure.
- Rules for reporting accidental discoveries outside the agreed scope.
