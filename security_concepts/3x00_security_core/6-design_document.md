## Executive Summary
#### REDACTION SPACE - MODIFICATIONS STATE: ONGOING...


## 1. Authentication Strategy
**Global Section Goal:** Clearly identify **`who`** performs actions.

- ### **Selected Technology**
**The Gold Rule:** Passwords are banned. 

*Specify if it's a solution or not and reason(s)*<br>

|Name|Factor Type|Reason|Selected|
|:-:|:-:|:-------|:-------:|
|***Password-Based***|Knowledge|Violation of the gold rule, therefore this method is not allowed.|X|
|**OTP (One-Time Passcode)**|Knowledge|Seen as an alternative to One-Time Password and password itself, it is useful if used as a last-step process and an approach by randomness and variable length code.|✓|
|***SSO***|Knowledge|Too much centralized login process for financial activities.|X|
|**Biometric**|Inherence|Combined with factor method, biometric authentication is very useful because of the difficulty to duplicate biometric owner *(at that time)*.|✓|
|***Retina Scan***|Inherence|Even with sensitive level information, this method is overreact. Feels too much military and/or very sensitive locations authentication process *(e.g. governments datacenters)*|X|
|**FIDO2**|Possession|Combined with at least one of each other factor type, this method is excellent for sensitive informations like financial ones.|✓|
|***Voice Recognition***|Possession|Very important: this method could be efficient a few years ago, but that is not the case anymore. Because of the improvments of *A.I. and specialized tools*, our voices can be replicate with much more accurate as time continues. So, this method is no longer efficient for sensitive information.|X|

- **Final Choice (better for implementation):** `COMBINATION`<br>It respects the chain "something ***you know***, something ***you have***, something you ***are***". It will be always possible to break through the process, but this combination stays very solid at that time.

## 2. Authorization Model
**Global Section Goal:** Clearly identify **`what`** actions a user is allow to perform.
#### REDACTION SPACE - MODIFICATIONS STATE: ONGOING...


## 3. Accounting Architecture
**Global Section Goal:** Follow actions to establish an efficient timeline of events, very useful for **`tracability`** and **`non-repudiation`**.
#### REDACTION SPACE - MODIFICATIONS STATE: ONGOING...
