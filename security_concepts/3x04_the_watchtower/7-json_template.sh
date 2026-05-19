#!/bin/bash
cat > /etc/rsyslog.conf << 'EOF'
'template(name="json_fmt" type="string" string='{"time":"%timestamp%", "host":"%hostname%", "msg":"%msg%"}\n')'
EOF

