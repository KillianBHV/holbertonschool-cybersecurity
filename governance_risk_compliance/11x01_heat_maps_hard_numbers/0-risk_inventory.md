# Risk Inventory

| ID | Asset | Threat | Vulnerability | Existing controls |
|:---|:---|:---|:---|:---|
| R1 | Suppliers payments / Finance processes | CEO-fraud phishing / Payment-fraud attempts | 1. No callback-verification procedure<br>2. Email filtering is basic | Basic email filtering |
| R2 | Claims platform / claims processing | Ransomware attack | 1. Aging Windows servers<br>2. Backups have never been tested *(for restoration)* | Nightly backups |
| R3 | Laptops *(containing **claim photos** and **policyholder PII**)* | Physical theft | No full-disk encryption | None identified |
| R4 | CRM / Commercial policyholder list | Insider Threat / Data exfiltration | Excessive access rights | Standard CRM access controls |
| R5 | Customer-portal *(self-service portal)* | Data exposure / Unauthorized access | Cloud misconfiguration | None identified |
| R6 | Quoting-engine SaaS *(via the vendor)* | Third-party SaaS outage *(vendor failure)* | No offline fallback process | SaaS cloud hosting *(by the vendor)* |
| R7 | Public website *(marketing-only)* | DDoS attack | Hosted directly on-premise | None identified |
| R8 | Claims files *(containing **health data**)* | Regulatory non-compliance / Date retention failure | 1. No data retention policy applied<br>2. Inefficient retrieval process *("takes weeks)* | Archive storage |
