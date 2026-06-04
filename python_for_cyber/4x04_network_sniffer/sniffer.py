#!/usr/bin/env python3

import sys

try:
    import scapy
except ModuleNotFoundError:
    print(hasattr(scapy, 'Packet'), scapy.__version__, file=sys.stderr)
    print("Module Not Found!", file=sys.stderr)
    print([path for path in sys.path])
    exit(1)


print("[INFO] PySniffer initialized")
