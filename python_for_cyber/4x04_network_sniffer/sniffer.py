#!/usr/bin/env python3

import argparse
from scapy.all import IP, TCP, UDP, ICMP, hexdump, sniff

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


def packet_handler(packet) -> None:
    """Get packet details
    """
    if IP in packet:
        tcp_check = False
        udp_check = False
        icmp_check = False

        if TCP in packet:
            tcp_check = True
        elif UDP in packet:
            udp_check = True
        elif ICMP in packet:
            icmp_check = True

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
