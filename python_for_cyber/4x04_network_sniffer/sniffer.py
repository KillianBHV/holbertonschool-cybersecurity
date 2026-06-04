#!/usr/bin/env python3

import argparse
from scapy.all import *
from scapy.packet import Packet

parser = argparse.ArgumentParser(
    prog="PySniffer",
    description="Capture packets"
)

parser.add_argument("-i", "--interface", help="Interface to sniff")
parser.add_argument("-f", "--filter", help="BPF filter to use")
parser.add_argument("-v",
                    "--verbose",
                    help="Verbose mode",
                    action="store_true")

args = parser.parse_args()
sniff_args = {"store": False}

if args.interface:
    sniff_args["iface"] = args.interface
if args.filter:
    sniff_args["filter"] = args.filter


def packet_handler(packet):
    """Get packet details
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

        if args.verbose:
            hexdump(packet)


def main() -> None:
    """Entry Point
    """
    print("[INFO] PySniffer initialized.")

    try:
        sniff(prn=packet_handler, **sniff_args)
    except KeyboardInterrupt:
        print("\n[INFO] Stopping capture...")


if __name__ == '__main__':
    main()
