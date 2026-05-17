#!/bin/bash
cp /etc/rsyslog.conf /etc/rsyslog.conf.bak
sed -i 's/^#\(module(load="imtcp")\)/\1/' /etc/rsyslog.conf
sed -i 's/^#\(module(load="imudp")\)/\1/' /etc/rsyslog.conf
sed -i 's/^#\(input(type="imudp" port="514")\)/\1/' /etc/rsyslog.conf
sed -i 's/^#\(input(type="imtcp" port="514")\)/\1/' /etc/rsyslog.conf
systemctl restart rsyslog

