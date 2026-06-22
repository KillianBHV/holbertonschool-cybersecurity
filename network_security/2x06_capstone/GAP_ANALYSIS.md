# GAP ANALYSIS

## Executive Summary
The review of the available documentation identified several security weaknesses that could expose critical business systems and data to unauthorized access and/or disruption. It mostly remains on network separation traffic, limited security controls and uncentralized monitoring capabilities. Addressing these issues should be a priority in terms of the company's credibility, as well as in terms of raising awareness and implementing security measures.

## GAPS Identified
+ ### Flat Network
> **`Current State`**<br>The current infrastructure consists of a flat network where all systems reside in a single subnet without segmentation<br><br>
> **`Risk Impact`**<br>This architecture lacks of containment in case of compromise and get unrestricted access between systems<br><br>
> **`Future State (expected one)`**<br>Network segmentation should be implemented based on security zones (DMZ, LAN)

+ ### Firewall Protection
> **`Current State`**<br>No firewall is deployed<br><br>
> **`Risk Impact`**<br>Unauthorized network communications cannot be restricted or monitored<br><br>
> **`Future State (expected one)`**<br>Default-Deny firewall policy is the core of controlling inbound and outbound traffic

+ ### FTP Communications
> **`Current State`**<br>FTP is used for business operations (accounting team relies on it)<br><br>
> **`Risk Impact`**<br>Credentials and transferred data may be intercepted<br><br>
> **`Future State (expected one)`**Sensitive communications should be encrypted in transit

+ ### SSH Exposure
> **`Current State`**<br>SSH is accessible from the Internet (by anyone)<br><br>
> **`Risk Impact`**<br>Bruteforce or credential-based attacks may target administrative services<br><br>
> **`Future State (expected one)`**<br>Restricted administrative access through controlled and authenticated channels

+ ### Logging/Monitoring Strategy
> **`Current State`**<br>No logging strategy is documented<br><br>
> **`Risk Impact`**<br>Security incidents may remain undetected<br><br>
> **`Future State (expected one)`**<br>Implementation of centralized logging and monitoring capabilities

+ ### Endpoint Detection and Response
> **`Current State`**<br>No endpoint controls are mentioned<br><br>
> **`Risk Impact`**<br>Compromised devices may not be detected or contained<br><br>
> **`Future State (expected one)`**<br>Endpoints should be protected through centralized security controls

+ ### Database Protection
> **`Current State`**<br>Database is centralized but critical and requires isolation<br>
> **`Risk Impact`**<br>Unauthorized access to business data may occur<br><br>
> **`Future State (expected one)`**<br>Critical databases should be isolated from general user networks

+ ### Documentation and Governance
> **`Current State`**<br>No documentation and no dedicated security administration for ten years<br>
> **`Risk Impact`**<br>Security management, troubleshooting, and incident response capabilities are reduced.<br><br>
> **`Future State (expected one)`**<br>Security procedures and infrastructure documentation should be maintained

## The Risk Matrix
|Name|Area|Priority|
|---|---|---|
|Network Segmentation|Network Architecture|High|
|SSH exposure|Remote Access|High|
|Logging Strategy|Monitoring and Detection|Medium|
|Endpoint Controls|Endpoint Security|High|
|Firewall Protection|Network Security Controls|High|
|Documentation and Governance|Security Governance|Medium|
|Database Protection|Asset Protection|Critical|
|FTP Communications|Data Transmission|High|

## Preliminary recommandations
- Implement network segmentation by separate the current network into dedicated zones such as LAN, guest access, DMZ and critical server segments to reduce lateral movements risks and improve access control
- Introduce firewall technologies and adopt a default-deny policy to regulate communications
- Protect critical business assets, especially ensure authorized services and personnel only have access to their resources
- Secure Administrative access by restrict SSH access and enforce strong authentication mechanisms.
- Enforce endpoint security: implement one to improve threat detection and reduce endpoint-based attacks risks.
- Improve monitoring capabilities by establishing centralized logging processes to improve visibility and incident detection to act quickly. 
