## Cluster A: Scope Boundaries
### 1) Unlisted internal API, but “direct dependencies”
* **CAN:** Probably yes, if the API can be linked to the **“direct dependencies” wording in the scope**.
* **SHOULD:** yes, with caution if there is **confirmation** that it is indeed **a direct dependency** and that the analysis remains minimal.

### 2) Dev server found outside the signed /24
* **CAN:** No as is, because it **is not within the signed scope**. The fact that the client mentioned it verbally **is not necessarily sufficient**.
* **SHOULD:** No, either, unless the scope is formally amended.

### 3) IDOR with PII in the e-commerce application
* **CAN:** yes, if access remains within the authorized application and **is used to demonstrate the impact** of a flaw within the scope.
* **SHOULD:** yes, but only to the minimum extent necessary, proving the severity with **the smallest useful sample**, not with massive volumes of data.

## Cluster B: Incidental Discoveries
### 4) Personal fraud detected on an in-scope tool
* **CAN/SHOULD**: Yes, this is reportable because it is an incidental discovery in an in-scope system; the report must be submitted through the designated channel, without unnecessary dissemination.

### 5) Significant data obtained through in-scope analysis
* **CAN/SHOULD**: Yes, but with even greater caution in wording and distribution, as the content is more sensitive and potentially **subject to legal/regulatory implications**.

## Cluster C: Client Communication
### 6) Active attack
* **CAN/SHOULD**: Yes, I can and must notify immediately because an active, ongoing compromise takes precedence over the reporting timeline.

### 7) The fallback role
* **CAN/SHOULD**: Yes, I can and must share a preliminary overview only if the RoE provides for a fallback escalation to a designated contact, as the absence of the PM must not block a legitimate alert.

## Cluster D: Engagement Qualification
### 8) The Disaster Engagement
* **CAN/SHOULD**: No, I cannot and should not propose this red team because it lacks the authorization, scope, and minimum conditions for a safe engagement.

