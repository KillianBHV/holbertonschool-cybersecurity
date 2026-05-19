#!/bin/bash
cat << 'EOF'
'template(name="json_fmt" type="string" string='{"time":"%timestamp%", "host":"%hostname%", "msg":"%msg%"}\n')'
EOF | tee -a /etc/rsyslog.conf

