#!/bin/bash
dig _dmarc.astralis-cloud.example TXT +short | grep -Eo 'p=[a-z]+\;' | sed -E 's/(p=|;)//g' | head -1
