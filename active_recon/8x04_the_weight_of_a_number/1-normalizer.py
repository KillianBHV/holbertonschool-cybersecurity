#!/usr/bin/python3

import sys
import xml.etree.ElementTree as ET

tree = ET.parse(sys.argv[1])
root = tree.getroot()
findings = []

for child in root.findall('scandetails'):
    asset = child.get('targethostname')
    for item in child:
        item_id = f"F-NIK-{item.get('id')}"

        osvdb_id = int(item.get('osvdbid'))
        if osvdb_id:
            severity = 'high'
            confidence = 0.85
        else:
            severity = 'info'
            confidence = 0.15

        f = {
            'id': item_id,
            'asset': asset,
            'source': 'nikto',
            'desc': f"{item.find('description').text}",
            'severity': severity,
            'confidence': confidence
        }
        findings.append(f)

print(findings)
