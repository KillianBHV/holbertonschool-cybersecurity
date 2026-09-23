# CASE 2: The Scope Creep

## 1. What Happened (Factual Summary)
During a web application audit limited to `://clientcorp.com` and its APIs, a senior consultant at RedLine Security discovered a connection to an internal billing service that was **not included in the scope** (`://clientcorp.com`). Believing he was adding value to the report, he exploited a default administrator password on that server and accessed the banking information of 10,000 customers. The billing infrastructure actually **belonged to a third party (FinServe Inc.) under a SaaS contract**, making this access completely *illegal and unauthorized*. The client and FinServe filed **lawsuits for scope violation and PCI-DSS non-compliance**, resulting in the consultant’s suspension and the activation of RedLine’s liability insurance.

## 2. What rule(s), law(s), or professional standard(s) were violated
* **Mandatory Contractual Scope:** A direct violation of the scope boundary clause established by the initial contract, which is the only legal safeguard protecting the auditor from accusations of computer hacking. 
* **Cybercrime Laws and Compliance:** Unauthorized access to a third-party computer system without the consent of its rightful owner (FinServe Inc.) and violation of the strict rules of the PCI-DSS industry standard regarding the processing of credit card data.
* **Professional Standards (PTES / OWASP):** Failure to follow the escalation procedure. The standards prohibit continuing to operate a system once it falls outside the defined scope, requiring prior written approval (Change Request).

## 3. What the correct professional behavior would have been
As soon as the consultant discovered the incorrect firewall configuration and access to the internal billing subdomain, he should have stopped immediately. The professional course of action would have been to document this discovery in the report as a “network routing vulnerability” (without attempting to connect to it), or to immediately contact his project manager to submit a written addendum to the client in order to obtain explicit authorization from FinServe before testing the credentials.

## 4. What specific clause(s) in a pre-engagement document would have prevented this outcome
* **Strict Scope Boundary and Exclusion Clause:** A clause explicitly stipulating that access to any unlisted system, IP address, or subdomain is strictly prohibited, and that any violation renders the auditor’s legal protections null and void. 
* **Scope Modification Procedure Clause (Change Control / Out-of-Scope Discovery):** A clause defining the protocol if an auditor discovers a critical vulnerability outside the scope: the obligation to suspend testing in that area, notify the client in writing, and obtain a signed amendment to expand the scope. 
* **Third-Party Infrastructure Exclusion Clause (SaaS/Cloud):** A clause stating that the client may not authorize the audit of systems that do not belong to them *(such as FinServe’s SaaS)* without a tripartite agreement.
