# VPN Design
## Topology
- Remote users → VPN Gateway (DMZ)
- VPN Gateway → internal routing firewall
No direct VPN-to-LAN access (always filtered via firewall rules)

# IP Addressing Scheme
LAN: **10.10.0.0/16**<br>
DMZ: **10.20.0.0/24**<br>
VPN Pool: **10.30.0.0/24**<br>
> VPN users get dynamic IPs from VPN pool only

## Access Control (VPN RBAC)
- **Admin Group**: Full access to management servers (SSH, RDP, monitoring)
- **Dev Group**: Access to dev/test environments only
- **Support Group**: Read-only access to logs and ticketing systems
> Enforced via firewall + VPN ACL mapping (not just authentication)
