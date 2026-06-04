#!/usr/bin/env python3

try:
    import scapy.all as scapy
    print(hasattr(scapy, 'Packet'), scapy.__version__)
except ModuleNotFoundError:
    print("Module Not Found!")
    exit(1)


print("[INFO] PySniffer initialized")
