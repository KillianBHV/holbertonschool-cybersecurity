#!/usr/bin/env python3

import scapy.all as scapy


def packet_handler(packet):
    """Get packet summary
    """
    print(packet.summary())


if __name__ == '__main__':
    print("[INFO] PySniffer initialized.")
    scapy.sniff(count=5, prn=packet_handler)
