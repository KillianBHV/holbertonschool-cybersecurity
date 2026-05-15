# ApexVault - Security Design Document
## Executive Summary
As a secure storage system design for VIP clients, ApexVault requires strict confidentiality, integrity and restrictive administrative access.<br>The system follows a `zero-trust security model` (no internal component is inherently trusted, including administrators and infrastructure) and enforces strong cryptographic protections to ensure that sensitive data remains inaccessible to unauthorized parties.

## 1. Authentication Strategy

### Selected Technology
We use `FIDO2 / WebAuthn` (passwordless authentication using crypptographic key pairs stored on a secure user device such as a hardware token or biometric system like fingerprint/face recognition).

### Justification
This method is selected because it provides phishing-resistant auhtentication (credentials cannot be reused or intercepted like passwords or SMS codes).<br>Compared to traditional authentication methods:<br>
- Passwords: vulnerable to leaks, reuse, brute force attacks.
- SMS OTP: vulnerable to interception and SIM swapping.
- FIDO2/WebAuthn: authentication is bound to the physical device and cryptographic challenge-response.

### Final Result
No reusable secret exists on the server side, significantly reducing attack surface.

## 2. Authorization Model

### Model Selected
We use `**RBAC** (Role-Based Access Control: permissions are assigned based on predefined roles such as user, auditor, admin)` combined with `client-side encryption (data is encrypted before leaving the user's device)`.

### Admin Restriction
Even system administrators cannot access client data because of a `zero-knowledge architecture (the system never stores or has access to decryption keys)`.

### Technical Enforcement
- Data is encrypted on the client side before upload.
- Encryption keys are generated and stored only on the client side.
- The server stores only encrypted blobs (unreadable ciphertext).

### Final Result
Administrators can manage infrastructure but cannot decrypt or read client data under any circumstances 

## 3. Accounting Architecture

### Storage Location
Logs are stored in a **`centralized logging system (dedicated infrastructure separated from user-level servers to prevent tampering and isolation of audit data)`**

### Integrity Mechanism
We ensure log integrity using:
#### 1) Append-only logging, immuable logs.
#### 2) Cryptographic hash chaining, previous entry hash for linking.
#### 3) WORM  storage (Write Once Read Many): stored in a system that physically prevents modification or deletion.

### Final Result
- Tampering becomes directly detectable
- Deletion attempts are blocked or leave forensic traces
- Full audit trail is preserved
