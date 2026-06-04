#!/usr/bin/env python3

import scapy.all as scapy


def packet_handler(packet: scapy.Packet) -> None:
    """Get packet summary
    """
    if packet.haslayer(scapy.IP):
        tcp_check = packet.getlayer(scapy.TCP)
        udp_check = packet.getlayer(scapy.UDP)
        icmp_check = packet.getlayer(scapy.ICMP)

        if tcp_check is not None:
            print("[TCP] ", end='')
        elif udp_check is not None:
            print("[UDP] ", end='')
        elif icmp_check is not None:
            print("[ICMP] ", end='')

        if tcp_check or udp_check or icmp_check:
            print(f"{packet[scapy.IP].src} -> {packet[scapy.IP].dst}")


if __name__ == '__main__':
    print("[INFO] PySniffer initialized.")
    scapy.sniff(count=5, prn=packet_handler)
