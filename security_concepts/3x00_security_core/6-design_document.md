## Executive Summary
#### REDACTION SPACE - MODIFICATIONS STATE: ONGOING...


## 1. Authentication Strategy
**Global Section Goal:** Clearly identify **`who`** performs actions.

**The Gold Rule:** Passwords are banned. 

- ### **Selected Technology**
*Specify if it's a solution or not and reason(s)*<br>

|Name|Security Properties|Reason|Selected|
|:-:|:-:|:-------|:-------:|
|***Password-Based***|Knowledge|Violation of the gold rule, therefore this method is not allowed.|X|
|**OTP (One-Time Passcode)**|Knowledge/Possession Technology|Seen as an alternative to One-Time Password and password itself, it is useful if used as a last-step process and an approach by randomness and variable length code.|✓|
|***SSO***|Knowledge/Possession Technology|Centralized login process not safely applicable for financial activities.|X|
|**Biometric**|Inherence|Combined with factor method, biometric authentication is very useful because of the difficulty to duplicate biometric owner *(at that time)*.|✓|
|***Retina Scan***|Inherence|Even with sensitive level information, this access control model enforces strict restrictions used in highly sensitive environments *(e.g. governments datacenters)*. In the context of a commercial VIP storage system, it may introduce unnecessary operational constraints.|X|
|**FIDO2**|Knowledge/Possession Technology|Combined with at least one other security property, this method is excellent for sensitive informations like financial ones.|✓|
|***Voice Recognition***|Possession|Very important: this method could be efficient a few years ago, but that is not the case anymore. Because of the improvments of *A.I. and specialized tools*, our voices can be replicate with much more accurate as time continues. So, this method is no longer efficient for sensitive information.|X|

- **Final Choice (better for implementation):** `Biometric combined to FIDO2 and OTP`.<br>It respects the chain "something ***you know***, something ***you have***, something you ***are***". It will be always possible to break through the process, but this combination stays very solid at that time.
- This combination enforces the strength of authentication sequence, inherited from password and SMS code, with much more security. While passwords and SMS are more likely plain, raw information, this combination is much more specific information to have or to obtain.

## 2. Authorization Model
**Global Section Goal:** Clearly identify **`what`** actions a user is allow to perform.

**The Gold Rule:** Even the SysAdmin cannot read client files, only manage the server

- ### **Model Selected:** `RBAC (Role-Based Access Control)`
*An admin stays a user, he has to be on the same ruleset than other users.*

### ***Admin Restrictions - Concepts***
- Contents must be **`encrypted`** on either client side and server side.
- Never act directly as a root user, use correctly configured **`administration accounts`** instead.
- You can even **`deactivate`** the main root session on your system with the previous requirement .
- Be sure that **`only administration processes`** can be done with these accounts.
- Apply **`right permissions`** as you do it with other account units *(individuals, groups)*. Administrators are not supposed to see, access and/or modify data that does not concern them, or does not implied them.

## 3. Accounting Architecture
**Global Section Goal:** Follow actions to establish an efficient timeline of events, very useful for **`tracability`** and **`non-repudiation`**.
#### REDACTION SPACE - MODIFICATIONS STATE: ONGOING...
