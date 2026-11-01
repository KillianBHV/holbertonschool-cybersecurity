# Engagement Plan

To reach Thornbury’s database server via identity paths rather than system exploitation, we enforce an evidence-based cost/benefit rubric to prioritize cracking efforts.

## Cracking Priority Rubric and Stopping Rule
We score each recovered hash by weighing its expected access value against cracking effort. Expected value is defined by the identity’s proximity and likelihood of access to Thornbury’s database server, combined with the structural privilege gain it offers. Cracking effort is estimated by password entropy, hash type, and dictionary complexity. We prioritize hashes with high access value and low time cost. Our strict stopping rule dictates that cracking ceases immediately if a hash's time-to-crack estimate exceeds 45 minutes, or if a lower-cost path providing equivalent DB access is uncovered. We explicitly skip hashes whose computed time cost outweighs their access value.

## Credential Use and Material Without Plaintext
Recovered plaintext credentials have a defined use: they will be utilized to authenticate to intermediate services to map subsequent delegation paths. For captured material where a plaintext password is never obtained, the issue is addressed by employing Pass-the-Hash (PtH) or Pass-the-Ticket (PtT) techniques. This allows us to impersonate the identity asset directly across the domain, rendering the recovery of the actual plaintext string irrelevant to our progression.

## Domain Controller Records and Constraints
We anticipate that before we perform any active movement, the Domain Controller will record our presence through Kerberos Authentication Service and Ticket Granting Service logs, specifically tracking Event IDs 4768 and 4769. To guarantee safety, we establish a hard constraint: we will not touch or target the Domain Controller. The entire objective remains framed as an identity path problem, focusing solely on who the domain thinks we are.
