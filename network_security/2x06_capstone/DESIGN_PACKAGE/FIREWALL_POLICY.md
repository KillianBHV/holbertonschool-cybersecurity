# Firewall Policy
## Default Policies
> INPUT: **DROP** by default
> 
> FORWARD: **DROP** by default
> 
> OUTPUT: **ALLOW**

## Principle: Default deny everywhere
### Core Rule Set (Examples + Justification)
1. VPN Access Rule
- Allow WAN → VPN Gateway
- Required for remote access tunnel establishment
2. HTTPS Access to DMZ Services
- Allow: WAN → DMZ
- Justification: Exposed secure services only
3. FTP Secure Handling
- Allow LAN ↔ DMZ FTP Proxy ONLY (not WAN direct)
- Justification: Legacy system isolation
4. LAN Internal Services
- Allow: VPN subnet → specific LAN service ports
- Justification: Least privilege access for admins/users
5. Block Everything Else
- DROP all unspecified traffic
- Log dropped packets for detection

### Rule Ordering Rationale
> ESTABLISHED/RELATED traffic first (performance + stability)
> 
> VPN rules (must be reachable before anything else)
> 
> DMZ public services
> 
> LAN internal access rules
> 
> Explicit DROP + logging last
