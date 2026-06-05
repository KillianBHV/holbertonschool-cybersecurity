#!/usr/bin/env python3

import argparse
from scapy.all import wrpcap, sniff, Packet, IP, TCP, ICMP, UDP


class Sniffer:
    def __init__(self):
        self.processors = {
            "TCP": TCPProcessor(),
            "UDP": UDPProcessor(),
            "ICMP": ICMPProcessor()
        }

    def start(self):
        """sniffer start
        """
        args = self.get_cli_parser()
        sniff_args = {"store": False}

        if args.interface:
            self.interface = args.interface
            sniff_args["iface"] = self.interface

        if args.filter:
            self.filter_str = args.filter
            sniff_args["filter"] = self.filter_str

        if args.write:
            self.output_file = args.write

        try:
            sniff(prn=self._process_packet, **sniff_args)
        except KeyboardInterrupt:
            print("\n[INFO] Stopping capture...")

    def get_cli_parser(self):
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
        return parser.parse_args()

    def _process_packet(self, packet):
        """Get packet details
        """
        if packet.haslayer(IP):
            if packet.haslayer(TCP):
                self.processors["TCP"].process(packet)
            elif packet.haslayer(UDP):
                self.processors["UDP"].process(packet)
            elif packet.haslayer(ICMP):
                self.processors["ICMP"].process(packet)
            else:
                print("UNKNOWN:", packet)


class PacketProcessor:
    def process(self, packet):
        raise NotImplementedError


class TCPProcessor(PacketProcessor):
    def process(self, packet):
        print("[TCP]")


class UDPProcessor(PacketProcessor):
    def process(self, packet):
        print("[UDP]")


class ICMPProcessor(PacketProcessor):
    def process(self, packet):
        print("[ICMP]")


def main() -> None:
    """Entry Point
    """
    print("[INFO] PySniffer initialized.")
    sniffer = Sniffer()
    sniffer.start()


if __name__ == '__main__':
    main()
