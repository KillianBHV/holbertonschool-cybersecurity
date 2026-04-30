#!/bin/bash
scp skeleton.conf engineer@10.42.34.150:~/skeleton.conf && scp 2-panic.sh engineer@10.42.34.150:~/2-panic.sh && ssh engineer@10.42.34.150 "sudo bash ~/2-panic.sh && sudo nft -f ~/skeleton.conf && sudo nft list ruleset"
