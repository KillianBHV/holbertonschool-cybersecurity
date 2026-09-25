#!/bin/bash
dig _dmarc.astralis-cloud.example TXT +short | grep -Eo 'p=(none|quarantine|reject)' | sed -E 's/p=//g' | head -1
