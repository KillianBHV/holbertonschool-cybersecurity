# CASE 1: The Handshake Deal

## 1. What Happened (Factual Summary)
NorthBay Consulting initiated a network penetration test based solely on a verbal agreement over the phone with the client’s Chief Technology Officer (CTO). During the audit, the consultants exploited **an SQL injection** vulnerability and extracted **500 customer records containing addresses and package contents to demonstrate the impact**. Having not been informed of this engagement, the company’s General Counsel detected the activity via her SIEM and immediately reported it **as a data breach** to the data protection authority. The engagement was halted by a cease-and-desist order, and the consulting firm found itself embroiled in ***eight months of legal proceedings and regulatory investigations*** for unauthorized access.

## 2. What rule(s), law(s), or professional standard(s) were violated
* **Cybercrime Laws:** Violation of laws regarding fraudulent access to and unauthorized retention within an automated data processing system (such as the Godfrain Law in France or the Computer Misuse Act/CFAA internationally), as the CTO did not have the legal authority to grant this access.
* **Data Protection Regulations (GDPR / Data Protection Act):** Unauthorized and illegal extraction of personal data (500 customer records) without a valid contractual legal basis, resulting in a false mandatory data breach report.
* **Professional Standards (PTES & CREST):** Flagrant violation of Phase 1 of the PTES (Pre-engagement Interactions). A professional standard strictly prohibits initiating any technical order without a written “Authorization of Assessment” (AoA) duly signed by the company’s legal representative.

## 3. What the correct professional behavior would have been
The sales engineer (Account Manager) and the team leader at NorthBay should have categorically refused to begin the assignment on Monday without first receiving the contract documents, whether signed electronically or in person. Faced with the CTO’s enthusiasm, professional conduct requires calmly explaining that the absence of a written agreement puts the consulting firm and the client at serious legal risk. Furthermore, the technical consultants should have minimized their data collection (extracting 1 or 2 rows from the database is more than sufficient for a proof of concept/PoC; 500 rows constitutes unjustified data theft).

## 4. What specific clause(s) in a pre-engagement document would have prevented this outcome
* **Assessment Authorization Clause (AoA – Legal Signatory):** A clause explicitly stipulating that the engagement may not begin until it has been signed by the company’s legal representative with the authority to bind the company (the CEO or the Board), thereby rendering any verbal approval by a third party (the CTO) null and void.
* **Stakeholder Communication and Notification Clause:** A clause requiring the client to include the security monitoring team (SOC/SIEM) and the legal department (General Counsel) in the emergency contact list so that they are formally notified of the start of testing and the origin of the auditors’ IP addresses. 
* **Data Handling and Minimization Clause:** A clause that contractually limits the collection of evidence to the strict minimum necessary to demonstrate the vulnerability, prohibiting the mass exfiltration of customer information.
