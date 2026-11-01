# Engagement Plan

To reach Thornbury’s database server via identity paths rather than system exploitation, we enforce an evidence-based cost/benefit rubric to prioritize cracking efforts.

## Cracking Priority Rubric and Stopping Rule
We score each recovered hash by weighing its expected access value against cracking effort. Expected value is defined by the identity’s proximity and likelihood of access to Thornbury’s database server, combined with the structural privilege gain it offers. Cracking effort is estimated by password entropy, hash type, and dictionary complexity. We prioritize hashes with high access value and low time cost. Our strict stopping rule dictates that cracking ceases immediately if a hash's time-to-crack estimate exceeds 45 minutes, or if a lower-cost path providing equivalent DB access is uncovered. We explicitly skip hashes whose computed time cost outweighs their access value.

## Credential Use and Identity Verification Flow
Recovered plaintext credentials have a strictly defined use centered on an explicit pre-session verification flow. Before initiating any administrative session on Thornbury’s database server, we will validate the recovered identity against domain groups, roles, effective permissions, ACLs, and delegation paths. This validation step confirms whether the credential possesses verified administrative rights on the objective database server. Only after completing this identity-to-access relationship check will the material be used to establish an authorized session. For captured material where a plaintext password is never obtained, the issue is addressed by employing Pass-the-Hash (PtH) or Pass-the-Ticket (PtT) techniques following the same mandatory verification flow.

## Domain Controller Records and Constraints
We anticipate that before we perform any active movement, the Domain Controller will record our presence through Kerberos Authentication Service and Ticket Granting Service logs, specifically tracking Event IDs 4768 and 4769. To guarantee safety, we establish a hard constraint: we will not touch or target the Domain Controller. The entire objective remains framed as an identity path problem, focusing solely on who the domain thinks we are.
