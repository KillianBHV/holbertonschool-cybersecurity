# DNS Notes - Task 1

## Finding 1: Staging production
- Value: staging-quote.helix-maritime.example
- Source: CertWatch CT log query "helix-maritime.example"
- Retrieval Date: 2026-07-20

## Finding 2: Legacy subdomain with expired SSL
- Value: hlx-owa01.helix-maritime.example
- Source: CertWatch CT log entry expired 2021-09-10
- Retrieval Date: 2026-07-20

## Finding 3: Mail server IP
- Value: 198.51.100.25
- Source: passive MX record reconstruction via Passive DNS
- Retrieval Date: 2026-07-20

## Finding 4: TXT record (third-party service indicator)
- Value: v=spf1 include:spf.zephyrmail.example include:spf.marlinmail.example -all
- Source: Passive DNS TXT helix-maritime.example
- Retrieval Date: 2026-07-20
