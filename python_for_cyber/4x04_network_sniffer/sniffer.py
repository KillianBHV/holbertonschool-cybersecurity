#!/usr/bin/env python3

from scapy.all import *


def packet_handler(packet):
    """Get packet summary
    """
    if packet.haslayer(IP):
        tcp_check = packet.haslayer(TCP)
        udp_check = packet.haslayer(UDP)
        icmp_check = packet.haslayer(ICMP)

        if tcp_check:
            print("[TCP] ", end='')
        elif udp_check:
            print("[UDP] ", end='')
        elif icmp_check:
            print("[ICMP] ", end='')

        if tcp_check or udp_check or icmp_check:
            ip_src = packet[IP].src
            ip_dest = packet[IP].dst

            result = f"{ip_src}"
            if tcp_check:
                result += f":{packet[TCP].sport}"
            result += f" -> {ip_dest}"
            if tcp_check:
                result += f":{packet[TCP].dport}"
                result += f" | Flags: {packet[TCP].flags}"

            print(result)


if __name__ == '__main__':
    print("[INFO] PySniffer initialized.")

    try:
        sniff(prn=packet_handler, store=False)
    except KeyboardInterrupt:
        print("\n[INFO] Stopping capture...")
