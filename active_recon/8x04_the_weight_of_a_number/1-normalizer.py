#!/usr/bin/python3

import xml.etree.ElementTree as ET

tree = ET.parse('../reports/nikto.xml')
root = tree.getroot()
findings = []

for child in root.findall('scandetails'):
    asset = child.get('targethostname')
    for item in child:
        item_id = f"F-NIK-{item.get('id')}"

        f = {
            'id': item_id,
            'asset': asset,
            'source': 'nikto',
            'desc': f"{item.find('description').text}"
        }
        findings.append(f)

print(findings)
