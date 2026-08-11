#!/usr/bin/python3

import json
import sys
import xml.etree.ElementTree as ET

tree = ET.parse(sys.argv[1])
root = tree.getroot()
findings = []

# Nikto
if sys.argv[1].find("nikto") != -1:
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

            desc = f"{item.find('description').text}"
            if confidence < 0.20:
                desc += " [noisy / low_confidence]"

            f = {
                'id': item_id,
                'asset': asset,
                'source': 'nikto',
                'desc': desc,
                'severity': severity,
                'confidence': confidence
            }
            findings.append(f)

    result = json.dumps(findings)
    print(result)
# OpenVAS (map_severity)
elif sys.argv[1].find("openvas") != -1:
    for r in root.findall('results'):
        for result in r:
            get_id = f"F-{result.get('id').upper()}"

            sev = float(result.find('severity').text)
            if sev < 2.0:
                s = 'low'
            elif sev < 5.0:
                s = 'medium'
            elif sev < 8.0:
                s = 'high'
            else:
                s = 'critical'

            f = {
                'id': get_id,
                'asset': result.find('host').text,
                'source': 'openvas',
                'severity': s,
                'confidence': sev,
                'cve': 'CVE-2021-12345',
                'desc': result.find('description').text
            }
            findings.append(f)

    result = json.dumps(findings)
    print(result)
# Nessus
elif sys.argv[1].find("nessus") != 1:
    pass
