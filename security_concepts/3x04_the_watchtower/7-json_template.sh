#!/bin/bash
cat > /etc/rsyslog.conf << 'EOF'
'template(name="json_fmt" type="string" string="%TIMESTAMP:::date-rfc3339% %HOSTNAME% %syslogtag%%msg:::sp-if-no-1st-sp%%msg:::drop-last-lf%")'
EOF

