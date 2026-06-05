#!/usr/bin/env python3

import argparse
from scapy.all import PcapWriter, wrpcap, sniff


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
parser.add_argument("--write", help="Write result on file")

args = parser.parse_args()
sniff_args = {"store": False}

if args.interface:
    sniff_args["iface"] = args.interface
if args.filter:
    sniff_args["filter"] = args.filter

if args.write:
    writer = PcapWriter(args.write, append=True)
else:
    writer = None


def packet_handler(packet) -> None:
    """Get packet details
    """
    if writer is not None:
        wrpcap(writer, packet)


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
