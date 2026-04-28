# LINUX HARDENING
### Instructions
- You must execute the `harden.sh` script, not other separate scripts
- Only execute as root is allowed

## LIBRARY - MODULES
### [identity.sh](https://github.com "Access Policy")
Access policy points such as:
- Non-root password
- Useless users deletion
- Repetitive connexions locked; password constraints
### [network.sh](https://github.com "Network Rules")
- Firewall default policy
- Only ports allowed
- No ip forwarding and ICMP consideration
- **[NOTA]** The firewall service must be active in production environment (only config matters in this lab)
### [ssh.sh](https://github.com "SSH Policy")
- Password authentication completely forbidden + non-root login allowed 
- **[NOTA]** Don't forget to restart the daemon in production environment (not required in this lab)
### [system.sh](https://github.com "System Rules")
- Checking packets are up-to-date
- Remove bloatwares
- Install required tools
