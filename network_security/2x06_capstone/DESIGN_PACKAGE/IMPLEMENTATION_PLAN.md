# Implementation Sequence
## Phase 1 — Foundation
- Deploy new firewall rules in monitor mode
- Enable logging for all drops
- Do NOT enforce DROP yet

## Phase 2 — VPN Deployment
- Deploy VPN gateway in DMZ
- Test remote connectivity
- Validate IP pool + authentication

## Phase 3 — Segmentation
- Introduce LAN/DMZ separation rules
- Gradually enforce default DROP on FORWARD chain

## Phase 4 — Service Migration
- Move FTP into DMZ proxy architecture
- Redirect traffic via controlled path

## Phase 5 — Enforcement Mode
- Enable strict default deny
- Remove temporary allow rules

# Rollback Plan
- Phase 1: Disable logging-only rules → revert to old firewall config
- Phase 2: Shut down VPN gateway
- Phase 3: Re-enable flat network routing temporarily
- Phase 4: Restore direct FTP internal routing (isolated but functional)
- Phase 5: Switch firewall policy back to permissive baseline snapshot
