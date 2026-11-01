# Engagement Plan

To reach Thornbury’s database server via identity paths rather than system exploitation, we enforce a strict binary triage rubric for all recovered cryptographic material. 

## Cracking Priority Rubric and Stopping Rule
We evaluate every collected hash using an explicit cost/benefit decision rule: target a hash if and only if it belongs to an identity directly nested within the access control path leading to Thornbury's database server. We assign a strict time budget of exactly 30 minutes per hash using a standard wordlist. If a hash is not cracked within this 30-minute window, our stopping rule triggers immediately, and the material is permanently skipped to preserve engagement hours. Machine-generated service accounts with high-entropy structures (>60 bits) are explicitly labeled "don't crack" and skipped entirely.

## Credential Use and Material Without Plaintext
Recovered plaintext credentials have a defined use: they will be utilized to authenticate to intermediate services to map subsequent delegation paths. For captured material where a plaintext password is never obtained, the issue is addressed by employing Pass-the-Hash (PtH) or Pass-the-Ticket (PtT) techniques. This allows us to impersonate the identity asset directly across the domain, rendering the recovery of the actual plaintext string irrelevant to our progression.

## Domain Controller Records and Constraints
We anticipate that before we perform any active movement, the Domain Controller will record our presence through Kerberos Authentication Service and Ticket Granting Service logs, specifically tracking Event IDs 4768 and 4769. To guarantee safety, we establish a hard constraint: we will not touch or target the Domain Controller. The entire objective remains framed as an identity path problem, focusing solely on who the domain thinks we are.
