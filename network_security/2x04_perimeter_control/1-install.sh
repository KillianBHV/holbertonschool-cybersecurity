#!/bin/bash
apt-get -y update && apt-get -y install nftables && apt-get -y install wireguard wireguard-tools && systemctl enable nftables
